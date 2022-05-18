class CheckActiveAlertsJob
    include Sidekiq::Worker
    sidekiq_options :retry => false
    def perform(*args)
        
        @alerts=ActiveAlert.all
        @alerts.each do |alert|
            if alert.new == true && (Time.now - alert.created_at)/60 > 10
                alert.update(new: false)
            else
                alert.update(new: true)
            end
        end

    end
end