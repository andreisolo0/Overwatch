require 'sidekiq-scheduler'
class PingJob
    include Sidekiq::Worker
    sidekiq_options :retry => false
    
    def perform(*args)
        ip_address_or_fqdn = Host.find(args[0]).ip_address_or_fqdn
        check = Net::Ping::External.new(ip_address_or_fqdn, count = 1)
        Host.find(args[0]).update(online: check.ping?)
    end
end
