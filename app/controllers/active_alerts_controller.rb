class ActiveAlertsController < ApplicationController

    def index
        @active_alerts = ActiveAlert.all
    end
    
    def destroy
        alert = ActiveAlert.find(params[:id])
        alert.destroy
    end
end