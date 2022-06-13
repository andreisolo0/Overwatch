class RemoteActionsController < ApplicationController
    before_action :require_user
    before_action :set_action, only: %i[ show edit update destroy ]
    before_action :permit_edit_own_action_or_admin, only: [:edit, :update, :destroy]
    

    def new
        @remote_action = RemoteAction.new
    end

    def create
        @remote_action = RemoteAction.new(params.require(:remote_action).permit(:action_name, :command_or_script, :path_to_script, :script))
        @remote_action.user = current_user
        if @remote_action.save
            flash[:notice] = "#{@remote_action.action_name} created"
            redirect_to remote_actions_path
        else
            render 'new'
        end
        
    end

    def edit

    end

    def update
        if @remote_action.update(remote_action_params)
            flash[:notice] = "Action #{@remote_action.action_name} was updated successfully"
            redirect_to @remote_action
       else
          render 'edit'
       end

    end

    def index
        @remote_actions = RemoteAction.paginate(page: params[:page], per_page: 25)
    end


    def show

    end

    
    def destroy
    
        @remote_action.destroy
        redirect_to remote_actions_path
    end

    
    def test_connection
        
        host = Host.find(params[:format])
        
        begin
            Net::SSH.start(host.ip_address_or_fqdn, host.user_to_connect, :password => host.password, :port => host.ssh_port, non_interactive: true) do |ssh|
                
            end
        rescue Net::SSH::AuthenticationFailed
            flash[:warn] = "SSH authentiction failed. Check credentials!"
        rescue Errno::ECONNREFUSED
            flash[:warn] = "SSH connection refused"
        rescue Errno::EHOSTUNREACH
            @error = "Host unreacheable - no route to host"
        else
            flash[:notice] = "Connection succesfully"
        
        end
        redirect_to host
    end

    def apply_remote_action
        require "net/scp"
        @host = Host.find(params[:host_id])
        @remote_action = RemoteAction.find(params[:remote_action_id])
        begin
            if @remote_action.script 
                Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                    if @host.run_as_sudo 
                        File.open("/tmp/deploy.file", "w") { |f| f.write "#{@remote_action.command_or_script}" }
                        sudo_pass="echo -e \"#{@host.password}\n\" | "
                        ssh.scp.upload!("/tmp/deploy.file", "#{@remote_action.path_to_script}")
                        ssh.exec! sudo_pass+"sudo -S chmod +x #{@remote_action.path_to_script}"
                        ssh.exec! sudo_pass+"sudo -S sed -i.bak s/\r//g #{@remote_action.path_to_script}"
                        output=(ssh.exec! sudo_pass+"sudo -S #{@remote_action.path_to_script}")
                    else
                        #ssh.exec! "touch #{@remote_action.path_to_script}"
                        #ssh.exec! "printf \"#{command}\" > #{@remote_action.path_to_script}"
                        #ssh.exec! "sed -i.bak s/\r//g #{@remote_action.path_to_script}"
                        #
                        File.open("/tmp/deploy.file", "w") { |f| f.write "#{@remote_action.command_or_script}" }
                        ssh.scp.upload!("/tmp/deploy.file", "#{@remote_action.path_to_script}")
                        ssh.exec! "chmod +x #{@remote_action.path_to_script}"
                        ssh.exec! "sed -i.bak s/\r//g #{@remote_action.path_to_script}"
                        output=(ssh.exec! "#{@remote_action.path_to_script}")
                    end
                    @message = "Command \"#{@remote_action.action_name}\" returned:\n" + output #@actions.script_content
                    if output.empty?
                        @message="Command produced no output"
                    end
                    respond_to do |format|
                        format.js { render partial: 'remote_actions/result' }
                    end
                end
                
            else
                Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                    if @host.run_as_sudo 
                        sudo_pass="echo -e \"#{@host.password}\n\" | "
                        output=(ssh.exec! sudo_pass+"sudo -S "+@remote_action.command_or_script)
                        
                    else
                        output=(ssh.exec! @remote_action.command_or_script)
                    end
                    @message = "Command \"#{@remote_action.action_name}\" returned:\n" + output #@actions.script_content
                    if output.empty?
                        @message="Command produced no output"
                    end
                    respond_to do |format|
                        format.js { render partial: 'remote_actions/result' }
                    end
                   
                end
            end
        rescue Net::SSH::AuthenticationFailed
            respond_to do |format|
                flash.now[:alert] = "SSH authentiction failed. Check credentials!"
                format.js { render partial: 'remote_actions/result' }
            end

        rescue Errno::ECONNREFUSED
            respond_to do |format|
                flash.now[:alert] = "SSH connection refused"
                format.js { render partial: 'remote_actions/result' }
            end
        rescue Errno::EHOSTUNREACH
            respond_to do |format|
                flash.now[:alert] = "Host unreachable - No route to host"
                format.js { render partial: 'remote_actions/result' }
            end
        end
        
        #redirect_to @action #this keeps the same page but shows warn
        #render "remote_actions/show" #this renders the show view of remote_actions with the @message var 
      
    end
    
    private
    def remote_action_params
        params.require(:remote_action).permit(:action_name, :command_or_script, :path_to_script, :script)
    end

    def permit_edit_own_action_or_admin
        if current_user.id != @remote_action.user_id && current_user.admin != true
            flash[:alert] = "You don't have rights to modify this action"
            redirect_to remote_actions_path
        end
    end

    def set_action
        @remote_action = RemoteAction.find(params[:id])
    end

    
end
