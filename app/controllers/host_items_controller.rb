class HostItemsController < ApplicationController

    def init_value_for_host_item(host_id,item_id)
        @host=Host.find(host_id)
        @item=Item.find(item_id)
        begin
            Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                @returned_value=(ssh.exec! @item.command_to_read)
            end
        rescue Net::SSH::AuthenticationFailed
            @error = "SSH authentiction failed. Check credentials!"
        rescue Errno::ECONNREFUSED
            @error = "SSH connection refused"
        rescue Errno::EHOSTUNREACH
            @error = "Host unreacheable - no route to host"
        else
            @error = "Connection succesfully"
        end
        [@returned_value,@error]
    end
    def new
        @host_item = HostItem.new
    end
    def create
        init_value = init_value_for_host_item(params[:host_id],params[:item_id])
        if init_value[0].nil?
            flash[:warn]="Item could not be read/assigned | "+init_value[1]
        else
            host_item = HostItem.create(host: @host, item: @item, value: init_value[0] )
            
            if Host.find(params[:host_id]).assigned_items_host.include?(params[:item_id].to_i) == false
                assigned_now = Host.find(params[:host_id]).assigned_items_host
                assigned_now << params[:item_id]
                Host.find(params[:host_id]).update(assigned_items_host: assigned_now)
            end
        end
        redirect_to @host
    end


    def schedule_collector_job
        # Set a schedule for the item to be read for each host
        job_name="job_for_item_"+ params[:item_id]+"_on_host_"+params[:host_id]
        run_interval = Item.find(params[:item_id]).interval_to_read
        #No longer needed since we have a file which is loaded on server start and reloads every periodically
        #Use this to schedule one time and not persist after restart
        #Sidekiq.set_schedule(job_name, { 'every' => [run_interval+"m"], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] })

        # To persist the schedule even after a sidekiq restart we need to save the schedule to a file
        scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
        
        if scheduler_data.include?(job_name) == false
            scheduler_data[job_name] = { 'every' => [run_interval+"m"], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] }
            File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                f.write(YAML.dump(scheduler_data))
            end
        end
        Sidekiq.set_schedule(job_name, { 'every' => [run_interval+'m'], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] })
        flash[:notice]="Job scheduled"
        redirect_to Host.find(params[:host_id])
    end

    def triggers
        @host_item = HostItem.find(params[:id])
        @host = Host.find(@host_item.host_id)
        @item = Item.find(@host_item.item_id)

    end
    def update 
        @host_item = HostItem.find(params[:id])
        @host = Host.find(@host_item.host_id)
        if @host_item.update(host_item_params)
            # This might be better handled and check wheter is neccesarilly to update all values from table
            HostItem.where(host_id: @host_item.host_id, item_id: @host_item.item_id).update(threshold_high: @host_item.threshold_high, threshold_warning: @host_item.threshold_warning, threshold_low: @host_item.threshold_low, 
                                                                                    alert_name_high: @host_item.alert_name_high, alert_name_warning: @host_item.alert_name_warning, alert_name_low: @host_item.alert_name_low, 
                                                                                    recovery_high: @host_item.recovery_high, recovery_warning: @host_item.recovery_warning, recovery_low: @host_item.recovery_low)
            flash[:notice] = "Triggers & Alerts set"
            redirect_to @host
        end
    end

    def destroy
        @host = Host.find(params[:id])
        # Destroy all item values for this host
        HostItem.destroy_by(host_id: params[:id], item_id: params[:item_id])
        # Update assigned_items_host column for this host
        assigned_now = @host.assigned_items_host
        assigned_now.delete(params[:item_id].to_i)
        Host.find(params[:id]).update(assigned_items_host: assigned_now)
        # Open scheduler to remove the job
        scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
        job_name="job_for_item_"+ params[:item_id]+"_on_host_"+@host.id.to_s
        scheduler_data.delete(job_name)
        File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
            f.write(YAML.dump(scheduler_data))
        end
        Sidekiq.remove_schedule(job_name)
        ActiveAlert.where(host_id: params[:id], item_id: params[:item_id]).destroy_all
        flash[:notice]="The item values and related jobs were removed"
        redirect_to @host
    end
    private
    def host_item_params
        #byebug
        params.require(:host_item).permit( :threshold_high, :threshold_warning, :threshold_low, :alert_name_high, :alert_name_warning, :alert_name_low, :recovery_high, :recovery_low, :recovery_warning)
    end
end
