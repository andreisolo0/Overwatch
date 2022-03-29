class ApplicationController < ActionController::Base
    
    helper_method :current_user, :logged_in?
    def current_user
        # to avoid multiple queries to database, we make the query only if current_user doesn't exist
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end


    def logged_in?
        # make current_user return a boolean
        !!current_user 
    end
end
