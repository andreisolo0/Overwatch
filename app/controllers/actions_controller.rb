class ActionsController < ApplicationController
    def test_connection
        host = Host.find(params[:format])
        byebug
        begin
            Net::SSH.start(host.ip_address_or_fqdn, host.user_to_connect, :password => host.password, :port => host.ssh_port, non_interactive: true) do |ssh|
                # 'ssh' is an instance of Net::SSH::Connection::Session
                #ssh.exec! "echo 'Test with arguments' > /home/pi/ssh_test
                #    ssh.exec! "echo 'Test with arguments' > /home/pi/ssh_test" @actions.script_content
            end
        rescue Net::SSH::AuthenticationFailed
            flash[:warn] = "SSH authentiction failed. Check credentials!"
        rescue Errno::ECONNREFUSED
            flash[:warn] = "SSH connection refused"
        else
            flash[:notice] = "Connection succesfully"
        end
        redirect_to host
    end
end
