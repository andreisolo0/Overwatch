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

    
end
