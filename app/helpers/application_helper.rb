module ApplicationHelper

    #helpers give methodsvariables just for the views. To have this methods and the variables in controllers write them in application controller
    #def current_user
        # to avoid multiple queries to database, we make the query only if current_user doesn't exist
    #    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    #end
    # moved to application_controller as helper_method



    #def logged_in?
        # make current_user return a boolean
    #    !!current_user 
    #end
    # moved to application_controller as helper_method
end
