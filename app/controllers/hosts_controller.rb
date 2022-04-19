class HostsController < ApplicationController
    before_action :require_user
    before_action :set_host, only: %i[ show edit update destroy assigned_items]
    before_action :permit_edit_own_host_or_admin, only: [:edit, :update, :destroy]
    
    def assigned_items
        @items = @host.items
    end

    def new
        @host = Host.new
    end

    def create
        @host = Host.new(host_params)
        @host.user = current_user
        
        if @host.save
            flash[:notice] = "#{@host.hostname} created"
            # Add job for ping on each host creation
            # Save job to file schedule to be loaded in case of server restart
            job_name="ping_#{@host.hostname}"
            run_interval = '1m'
            scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
            if scheduler_data.include?(job_name) == false
                scheduler_data[job_name] = { 'every' => [run_interval], 'class' => 'PingJob', 'args' => [@host.id] }
                File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                    f.write(YAML.dump(scheduler_data))
                end
            end
            Sidekiq.set_schedule(job_name, { 'every' => [run_interval], 'class' => 'PingJob', 'args' => [@host.id] })
            redirect_to hosts_path
        else
            render 'new'
        end
        
    end

    def edit
        
    end

    def update
        
        if @host.update(host_params)
            if host_params[:autopatch] == "1" && @host.online == true
                job_name="autopatch_#{@host.hostname}"
                run_interval = '1d'
                scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
                if scheduler_data.include?(job_name) == false
                    scheduler_data[job_name] = { 'every' => [run_interval], 'class' => 'AutopatchJob', 'args' => [@host.id] }
                    File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                        f.write(YAML.dump(scheduler_data))
                    end
                end
                Sidekiq.set_schedule(job_name, { 'every' => [run_interval], 'class' => 'AutopatchJob', 'args' => [@host.id] })
            else
                job_name="autopatch_#{@host.hostname}"
                scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
                scheduler_data.delete(job_name)
                File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                    f.write(YAML.dump(scheduler_data))
                end
                Sidekiq.remove_schedule(job_name)
            end
            flash[:notice] = "Host #{@host.hostname} was updated successfully"
            redirect_to @host
       else
          render 'edit'
       end

    end

    def index
        #@hosts = Host.all
        @hosts = Host.paginate(page: params[:page], per_page: 25)
    end


    def show
        #@host = Host.find(params[:id])
        assigned_items
    end

    
    def destroy
        #No longer needed because we have before_action @article = Article.find(params[:id])
        scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
        job_name="ping_#{@host.hostname}"
        scheduler_data.delete(job_name)
        File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
            f.write(YAML.dump(scheduler_data))
        end
        Sidekiq.remove_schedule(job_name)
        @host.destroy
        redirect_to hosts_path
      end
    

    def show_actions
        @remote_actions=RemoteAction.where(user_id: @host.user_id)
    end
    private
    def host_params
        #byebug
        params.require(:host).permit( :ip_address_or_fqdn, :hostname, :user_to_connect, :password, :ssh_port, :run_as_sudo, :autopatch)
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