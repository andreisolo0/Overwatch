require 'sidekiq-scheduler'
class ScheduleItemJob
    include Sidekiq::Worker
    sidekiq_options :retry => false

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
    
    def perform(*args)
        host_id=args[0]
        item_id=args[1]
        init_value = init_value_for_host_item(host_id,item_id)
        if init_value[0].nil?
            @host_item = HostItem.create(host: @host, item: @item, value: "ERR:"+init_value[1] )
        else
            @host_item = HostItem.create(host: @host, item: @item, value: init_value[0] )   
        end
    end
end