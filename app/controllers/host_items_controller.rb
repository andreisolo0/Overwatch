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
        #GetItemJob.perform_async(params[:host_id],params[:item_id])
        # Set a schedule for the item to be read for each host
        job_name="job_for_item_"+ params[:item_id]+"_on_host_"+params[:host_id]
        run_interval = Item.find(params[:item_id]).interval_to_read
        Sidekiq.set_schedule(job_name, { 'every' => [run_interval+"m"], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] })

        # To persist the schedule even after a sidekiq restart we need to save the schedule to a file
        #scheduler = File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'))
        scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
        #scheduler_data = scheduler_data[:schedule]
        #byebug
        if scheduler_data.include?(job_name) == false
            scheduler_data[job_name] = { 'every' => [run_interval+"m"], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] }
            File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                #byebug
                f.write(YAML.dump(scheduler_data))
            end
        end
        
        flash[:notice]="Job scheduled"
        redirect_to Host.find(params[:host_id])
    end

    def destroy
        @host = Host.find(params[:id])
        HostItem.destroy_by(host_id: params[:id], item_id: params[:item_id])
        assigned_now = @host.assigned_items_host
        assigned_now.delete(params[:item_id].to_i)
        
        Host.find(params[:id]).update(assigned_items_host: assigned_now)
        redirect_to @host
    end

end
