class Host < ApplicationRecord
    belongs_to :user
    has_many :host_items
    has_many :items, through: :host_items
    
    def online?
        Host.find(self.id).online
        # read the online status from the host table
    end

    #def ssh_available?
    #    begin
    #        Net::SSH.start(self.ip_address_or_fqdn, self.user_to_connect, :password => self.password, :port => self.ssh_port, non_interactive: true, :timeout => 2) do |ssh|
    #            authenticated=true
    #        end
    #    rescue Net::SSH::AuthenticationFailed
    #        authenticated=false
    #    rescue Errno::ECONNREFUSED
    #        authenticated=false
    #    rescue Errno::EHOSTUNREACH
    #        authenticated=false
    #    rescue Net::SSH::ConnectionTimeout
    #        authenticated=false
    #    end
    #end
end