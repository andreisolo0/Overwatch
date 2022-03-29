class HostsController < ApplicationController
    before_action :require_user
    before_action :permit_edit_own_host?, only: [:edit, :update, :destroy]

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
        @host = Host.find(params[:id])
        if @host.update(host_params)
            flash[:notice] = "Host #{@host.hostname} was updated successfully"
            redirect_to @host
       else
          render 'edit'
       end

    end

    def index
        #@hosts = Host.all
        @hosts = Host.paginate(page: params[:page], per_page: 3)
    end


    def show
        @host = Host.find(params[:id])
    end

    private
    def host_params
        params.require(:host).permit( :ip_address_or_fqdn, :hostname)
    end

    def permit_edit_own_user?
        #Add after correlation between hosts and users
        #if current_user != @host.user
        #    flash[:alert] = "You don't have rights to edit this host"
        #    redirect_to @host
        #end
    end
end