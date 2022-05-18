class ActiveAlertsController < ApplicationController

    def index
        @active_alerts = ActiveAlert.all
    end
    
end