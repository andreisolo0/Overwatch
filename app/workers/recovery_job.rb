class RecoveryJob
    include Sidekiq::Worker
    sidekiq_options :retry => false
    require 'rubygems'
    require 'net/ssh'
    def ssh_exec!(ssh, command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
            end
            channel.on_data do |ch,data|
              stdout_data+=data
            end
      
            channel.on_extended_data do |ch,type,data|
              stderr_data+=data
            end
      
            channel.on_request("exit-status") do |ch,data|
              exit_code = data.read_long
            end
      
            channel.on_request("exit-signal") do |ch, data|
              exit_signal = data.read_long
            end
          end
        end
        ssh.loop
        [stdout_data, stderr_data, exit_code, exit_signal]
    end

    def perform(*args)
        @host=Host.find(args[0])
        @command=RemoteAction.find(args[1])
        @alert=ActiveAlert.find(args[2])
        exit_code=nil
        puts "Recovery job for on #{@host.hostname} started"
        Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                exit_code=(ssh.exec! @command.command_or_script)
        end
        @alert.update(new: false)
        if exit_code.exitstatus == 0 
            @alert.update(resolved: true)
            @alert.update(resolved_at: Time.now)
        else
            @alert.update(resolved: false)
        end
        puts "Recovery job for on #{@host.hostname} finished. Problem solved: #{@alert.resolved}"
    end

end