class HostsController < ApplicationController
    before_action :require_user
    before_action :set_host, only: %i[ show edit update destroy ]
    before_action :permit_edit_own_host_or_admin, only: [:edit, :update, :destroy]
    
    def new
        @host = Host.new
    end

    def create
        @host = Host.new(host_params)
        @host.user = current_user
        if @host.save
            flash[:notice] = "#{@host.hostname} created"
            redirect_to hosts_path
        else
            render 'new'
        end
        
    end

    def edit
        #@host = Host.find(params[:id])
    end

    def update
        #@host = Host.find(params[:id])
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
        #@host = Host.find(params[:id])
    end

    
    def destroy
        #No longer needed because we have before_action @article = Article.find(params[:id])
    
        @host.destroy
        redirect_to hosts_path
      end

    private
    def host_params
        params.require(:host).permit( :ip_address_or_fqdn, :hostname)
    end

    def permit_edit_own_host_or_admin
        #Add after correlation between hosts and users
        if current_user.id != @host.user_id && current_user.admin != true
            flash[:alert] = "You don't have rights to modify this host"
            redirect_to hosts_path
        end
    end

    def set_host
        @host = Host.find(params[:id])
    end
end