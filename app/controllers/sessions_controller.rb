class SessionsController < ApplicationController
    def new
        if logged_in?
            redirect_to root_path
        end
    end

    def create
        user = User.find_by(username: params[:session][:username])
        
        if user && user.authenticate(params[:session][:password])
            session[:user_id] = user.id
            flash[:notice] = "Logged in successfully"
            redirect_to root_path
        else
            # render is not a new request, no http cycle request, flash now + render to show in current page
            flash.now[:alert] = "Oopsie, seems like the username or password are wrong!"
            render 'new' 
        end
    end

    def destroy
        session[:user_id] = nil
        flash[:notice] = "Logged out"
        redirect_to root_path
    end

end