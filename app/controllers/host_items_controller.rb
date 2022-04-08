class HostItemsController < ApplicationController

    def init_value_for_host_item(host_id,item_id)
        @host=Host.find(host_id)
        @item=Item.find(item_id)
        begin
            Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                @returned_value=(ssh.exec! @item.command_to_read)
            end
        rescue Net::SSH::AuthenticationFailed
            flash[:warn] = "SSH authentiction failed. Check credentials!"
        rescue Errno::ECONNREFUSED
            flash[:warn] = "SSH connection refused"
        else
            flash[:notice] = "Connection succesfully"
        end
        @returned_value
    end
    def new
        @host_item = HostItem.new
    end
    def create
        init_value = init_value_for_host_item(params[:host_id],params[:item_id])
        @host_item = HostItem.create(host: @host, item: @item, value: init_value )
        
        redirect_to @host
    end

end
