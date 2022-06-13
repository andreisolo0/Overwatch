class AlertMailer < ApplicationMailer
    def new_alert_mail
        @alert_id = params[:alert_id]
        @alert = ActiveAlert.find(@alert_id)
        @host_id = ActiveAlert.find(@alert_id).host_id
        @host=Host.find(@host_id)
        @user = User.find(Host.find(@host.id).user_id)
        case @alert.severity
        when "high"
            @details = HostItem.find(@alert.host_item_id).alert_name_high
        when "warning"
            @details = HostItem.find(@alert.host_item_id).alert_name_warning
        when "low"
            @details = HostItem.find(@alert.host_item_id).alert_name_low
        end
        mail(from: "overwatch@solomon-andrei.com", to: @user.email , subject: "New Alert")
    end
end