class ActiveAlert < ApplicationRecord
    def send_mail
        AlertMailer.with(alert_id: self.id).new_alert_mail.deliver_now
    end
end