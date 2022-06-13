class ApplicationController < ActionController::Base
    
    helper_method :current_user, :logged_in?, :assigned_items_for_current__host
    def current_user
        # to avoid multiple queries to database, we make the query only if current_user doesn't exist
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end


    def logged_in?
        # make current_user return a boolean
        !!current_user 
    end

    def require_user
        if !logged_in?
            #flash[:alert] = "You need to be logged in to perform this action!"
            redirect_to forbidden_path
        end
    end
    def configuration
    
    end

    def save_configuration
        require 'yaml'
        
        @mail_server=params[:address]
        @port=params[:port]
        @username=params[:username]
        @password=params[:password]
        @auth=params[:auth]
        @tls=params[:tls]
        config={
            "mail_server"=>@mail_server,
            "port"=>@port,
            "username"=>@username,
            "password"=>@password,
            "auth"=>@auth,
            "tls"=>@tls
        }
        if @mail_server.present? && @port.present? && @username.present? && @password.present?
            File.open(Rails.root.join("config","mail_config.yml"), "w") { |file| file.write(config.to_yaml) }
            File.open(Rails.root.join("config","environments","development.rb"), "a") 
            
            flash[:notice] = "Configuration saved successfully!"
            redirect_to configuration_path
        else
            flash[:alert] = "Please fill all the fields!"
        end
    end

    
end
