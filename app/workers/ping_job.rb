require 'sidekiq-scheduler'
class PingJob
    include Sidekiq::Worker
    sidekiq_options :retry => false
    
    def perform(*args)
        ip_address_or_fqdn = Host.find(args[0]).ip_address_or_fqdn
        check = Net::Ping::External.new(ip_address_or_fqdn, count = 1)
        Host.find(args[0]).update(online: check.ping?)
        if Host.find(args[0]).online
            @host = Host.find(args[0])
            Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                @os=(ssh.exec! "egrep '^(PRETTY_NAME)=' /etc/os-release | cut -d= -f2").gsub(/\"/,"")
                @reboot_required=ssh.exec! "cat /var/run/reboot-required"
            end
            @host.update(os: @os)
            puts @reboot_required.include? "restart"
            if @reboot_required.include? "restart"
                @host.update(reboot_required: true)
            else
                @host.update(reboot_required: false)
            end
        end
    end
end
