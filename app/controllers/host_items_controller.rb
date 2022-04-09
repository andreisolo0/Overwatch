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
            flash[:warn]="Item could not be read | "+init_value[1]
        else
            host_item = HostItem.create(host: @host, item: @item, value: init_value[0] )
            
        end
        redirect_to @host
    end


    def schedule_collector_job
        #GetItemJob.perform_async(params[:host_id],params[:item_id])
        # Set a schedule for the item to be read for each host
        Sidekiq.set_schedule('Job for item '+ Item.find(params[:item_id]).item_name, { 'every' => ['1m'], 'class' => 'ScheduleItemJob', 'args' => [params[:host_id],params[:item_id]] })
        flash[:notice]="Job scheduled"
        redirect_to Host.find(params[:host_id])
    end

    def destroy
        @host = Host.find(params[:id])
        HostItem.destroy_by(host_id: params[:id], item_id: params[:item_id])
        
        redirect_to @host
    end

end
