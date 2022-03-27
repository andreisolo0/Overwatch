class HostsController < ApplicationController
    def new
        @host = Host.new
    end

    def create
        @host = Host.new(host_params)
        if @host.save
            flash[:notice] = "#{@host.hostname} created"
            redirect_to hosts_path
        else
            render 'new'
        end
        
    end

    def edit
        @host = Host.find(params[:id])
    end

    def update
        if @host.update(host_params)
            #flash[:notice] = "User #{user.username} was updated successfully"
            redirect_to hosts_path
       else
          render 'edit'
       end

    end

    def index
        @hosts = Host.all
    end


    def show
        @host = Host.find(params[:id])
    end

    private
    def host_params
        params.require(:host).permit( :ip_address_or_fqdn, :hostname)
    end
end