require 'sidekiq-scheduler'
class AutopatchJob
    include Sidekiq::Worker
    sidekiq_options :retry => false
    
    def perform(*args)
        @host=Host.find(args[0])
        Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
            if @host.run_as_sudo == true
                case @host.os.downcase
                when /ubuntu*/
                    ssh.exec! "sudo unattended-upgrade -d"
                when /redhat*/ , /centos*/
                    ssh.exec! "sudo yum update -y --security"
                when /fedora*/
                    ssh.exec! "sudo dnf update -y --security"
                end
            end
        end
        
    end
end
