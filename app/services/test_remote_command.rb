class TestRemoteCommand
    def initialize(ip_fqdn,port,username,password)
        @ip_fqdn= ip_fqdn
        @port = port
        @username = username
        @password = password
    end

    def connect
        Net::SSH.start("192.168.56.116", "asolomon", :password => "123456", :port => "22") do |ssh|
            # 'ssh' is an instance of Net::SSH::Connection::Session
            ssh.exec! "touch /home/pi/ssh_test_from_helper"
        end
    end
end
