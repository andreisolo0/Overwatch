require 'sidekiq-scheduler'
class ScheduleItemJob
    include Sidekiq::Worker
    sidekiq_options :retry => false

    def init_value_for_host_item(host_id,item_id)
        @host=Host.find(host_id)
        @item=Item.find(item_id)
        begin
            Net::SSH.start(@host.ip_address_or_fqdn, @host.user_to_connect, :password => @host.password, :port => @host.ssh_port, non_interactive: true) do |ssh|
                @returned_value=(ssh.exec! @item.command_to_read)
            end
        rescue Net::SSH::AuthenticationFailed
            @error = "SSH authentiction failed. Check credentials!"
        rescue Errno::ECONNREFUSED
            @error = "SSH connection refused"
        rescue Errno::EHOSTUNREACH
            @error = "Host unreacheable - no route to host"
        else
            @error = "Connection succesfully"
        end
        [@returned_value,@error]
    end
    
    def set_active_alert(active_alert_id,threshold_value,severity,host_item)
        @alert=ActiveAlert.find(active_alert_id)
        @alert.update(severity: severity, threshold: threshold_value)
        if severity=="high"
            host_item.update(active_high_id: @alert.id)
            host_item.update(active_warning_id: nil)
            host_item.update(active_low_id: nil)
            ActiveAlert.find(active_alert_id).update(host_item_id: host_item.id)
        elsif severity=="warning"
            host_item.update(active_high_id: nil )
            host_item.update(active_warning_id: @alert.id)
            host_item.update(active_low_id: nil)
            ActiveAlert.find(active_alert_id).update(host_item_id: host_item.id)
        elsif severity=="low"
            host_item.update(active_high_id: nil )
            host_item.update(active_warning_id: nil)
            host_item.update(active_low_id: @alert.id)
            ActiveAlert.find(active_alert_id).update(host_item_id: host_item.id)
        end
    end
    def perform(*args)
        host_id=args[0]
        item_id=args[1]
        if (Host.find(host_id).online)
            value = init_value_for_host_item(host_id,item_id) 
            #Get threshold values from last entry in case some value is set
            threshold_high=HostItem.where(host_id: host_id, item_id: item_id).last.threshold_high
            threshold_low=HostItem.where(host_id: host_id, item_id: item_id).last.threshold_low
            threshold_warning=HostItem.where(host_id: host_id, item_id: item_id).last.threshold_warning
            active_high_id=HostItem.where(host_id: host_id, item_id: item_id).last.active_high_id
            active_warning_id=HostItem.where(host_id: host_id, item_id: item_id).last.active_warning_id
            active_low_id=HostItem.where(host_id: host_id, item_id: item_id).last.active_low_id
            alert_name_high=HostItem.where(host_id: host_id, item_id: item_id).last.alert_name_high
            alert_name_warning=HostItem.where(host_id: host_id, item_id: item_id).last.alert_name_warning
            alert_name_low=HostItem.where(host_id: host_id, item_id: item_id).last.alert_name_low
            recovery_high=HostItem.where(host_id: host_id, item_id: item_id).last.recovery_high
            recovery_warning=HostItem.where(host_id: host_id, item_id: item_id).last.recovery_warning
            recovery_low=HostItem.where(host_id: host_id, item_id: item_id).last.recovery_low
            #Create entry in HostItem table where all values are stored
            if value[0].nil?
                @host_item = HostItem.create(host: @host, item: @item, value: "ERR:"+value[1], 
                    threshold_high: threshold_high,threshold_warning: threshold_warning, threshold_low: threshold_low, 
                    active_high_id: active_high_id, active_warning_id: active_warning_id, active_low_id: active_low_id, 
                    alert_name_high: alert_name_high, alert_name_warning: alert_name_warning,alert_name_low: alert_name_low, 
                    recovery_high: recovery_high, recovery_warning: recovery_warning, recovery_low: recovery_low)
            else
                value[0] = value[0].gsub("\n","")
                puts value[0].count("a-zA-Z")
                @host_item = HostItem.create(host: @host, item: @item, value: value[0], 
                    threshold_high: threshold_high,threshold_warning: threshold_warning, threshold_low: threshold_low, 
                    active_high_id: active_high_id, active_warning_id: active_warning_id, active_low_id: active_low_id, 
                    alert_name_high: alert_name_high, alert_name_warning: alert_name_warning,alert_name_low: alert_name_low, 
                    recovery_high: recovery_high, recovery_warning: recovery_warning, recovery_low: recovery_low)
                # Check what type of data the retrieved value/treshold is and convert it to float if it's the case
                
                if value[0].count("a-zA-Z") == 0
                    value=value[0].to_f
                else
                    value=value[0]
                end
                
                if !threshold_high.empty? and threshold_high.count("a-zA-Z") == 0
                    threshold_high=threshold_high.to_f
                end
                if !threshold_warning.empty? and threshold_warning.count("a-zA-Z") == 0
                    threshold_warning=threshold_warning.to_f
                end
                if !threshold_low.empty? and threshold_low.count("a-zA-Z") == 0
                    threshold_low=threshold_low.to_f
                end

                if value.is_a?(Float) && value != 0
                    @host_item=HostItem.where(host_id: host_id, item_id: item_id).last
                    if !threshold_high.nil? and value >= threshold_high
                        if @host_item.active_high_id.nil? and @host_item.active_warning_id.nil? and @host_item.active_low_id.nil?
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "high", threshold: threshold_high)
                            @host_item.update(active_high_id: @alert.id)
                            @host_item.update(active_warning_id: nil)
                            @host_item.update(active_low_id: nil)
                        elsif @host_item.active_high_id.nil? and !@host_item.active_warning_id.nil?
                            set_active_alert(@host_item.active_warning_id,threshold_high,"high",@host_item)
                        elsif @host_item.active_high_id.nil? and !@host_item.active_low_id.nil?
                            set_active_alert(@host_item.active_low_id,threshold_high,"high",@host_item)
                        else
                        ActiveAlert.find(@host_item.active_high_id).update(host_item_id: @host_item.id)
                        end
                    elsif !threshold_high.nil? and !threshold_warning.nil? and value >= threshold_warning and value < threshold_high  
                        if @host_item.active_warning_id.nil? and @host_item.active_low_id.nil? and @host_item.active_high_id.nil? 
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "warning", threshold: threshold_warning)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: @alert.id)
                            @host_item.update(active_low_id: nil)
                        elsif @host_item.active_warning_id.nil? and !@host_item.active_high_id.nil?
                            set_active_alert(@host_item.active_high_id,threshold_warning,"warning",@host_item)
                        elsif @host_item.active_warning_id.nil? and !@host_item.active_low_id.nil?
                            set_active_alert(@host_item.active_low_id,threshold_warning,"warning",@host_item)
                        else
                            ActiveAlert.find(@host_item.active_warning_id).update(host_item_id: @host_item.id)
                        end
                    elsif !threshold_low.nil? and !threshold_warning.nil? and value >= threshold_low and value < threshold_warning 
                        if @host_item.active_high_id.nil? and @host_item.active_warning_id.nil? and @host_item.active_low_id.nil?
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "low", threshold: threshold_low)
                            @host_item.update(active_low_id: @alert.id)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: nil)
                        elsif @host_item.active_low_id.nil? and !@host_item.active_high_id.nil?
                            set_active_alert(@host_item.active_high_id,threshold_low,"low",@host_item)
                        elsif @host_item.active_low_id.nil? and !@host_item.active_warning_id.nil?
                            set_active_alert(@host_item.active_warning_id,threshold_low,"low",@host_item)
                        else
                            ActiveAlert.find(@host_item.active_low_id).update(host_item_id: @host_item.id)
                        end
                    else
                        if !@host_item.active_warning_id.nil? or !@host_item.active_high_id.nil? or !@host_item.active_low_id.nil?
                            if !@host_item.active_low_id.nil?
                                ActiveAlert.find(@host_item.active_low_id).destroy
                            elsif !@host_item.active_warning_id.nil?
                                ActiveAlert.find(@host_item.active_warning_id).destroy
                            elsif !@host_item.active_high_id.nil?
                                ActiveAlert.find(@host_item.active_high_id).destroy
                            end
                            @host_item.update(active_low_id: nil)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: nil)
                        end
                    end
                end

                # Create Alerts if the value is a string
                if value.is_a?(String) && !value.empty?
                    @host_item=HostItem.where(host_id: host_id, item_id: item_id).last
                    if value == threshold_high
                        if @host_item.active_high_id.nil? and @host_item.active_warning_id.nil? and @host_item.active_low_id.nil?
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "high", threshold: threshold_high)
                            @host_item.update(active_high_id: @alert.id)
                            @host_item.update(active_warning_id: nil)
                            @host_item.update(active_low_id: nil)
                        elsif @host_item.active_high_id.nil? and !@host_item.active_warning_id.nil?
                            set_active_alert(@host_item.active_warning_id,threshold_high,"high",@host_item)
                        elsif @host_item.active_high_id.nil? and !@host_item.active_low_id.nil?
                            set_active_alert(@host_item.active_low_id,threshold_high,"high",@host_item)
                        end
                    elsif value == threshold_warning
                        if @host_item.active_high_id.nil? and @host_item.active_warning_id.nil? and @host_item.active_low_id.nil?
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "warning", threshold: threshold_warning)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: @alert.id)
                            @host_item.update(active_low_id: nil)
                        elsif @host_item.active_warning_id.nil? and !@host_item.active_high_id.nil?
                            set_active_alert(@host_item.active_high_id,threshold_warning,"warning",@host_item)
                        elsif @host_item.active_warning_id.nil? and !@host_item.active_low_id.nil?
                            set_active_alert(@host_item.active_low_id,threshold_warning,"warning",@host_item)
                        end
                    elsif value == threshold_low 
                        if @host_item.active_high_id.nil? and @host_item.active_warning_id.nil? and @host_item.active_low_id.nil?
                            @alert=ActiveAlert.create(host_item_id: @host_item.id, item_id: item_id, severity: "low", threshold: threshold_low)
                            @host_item.update(active_low_id: @alert.id)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: nil)
                        elsif @host_item.active_low_id.nil? and !@host_item.active_high_id.nil?
                            set_active_alert(@host_item.active_high_id,threshold_low,"low",@host_item)
                        elsif @host_item.active_low_id.nil? and !@host_item.active_warning_id.nil?
                            set_active_alert(@host_item.active_warning_id,threshold_low,"low",@host_item)
                        end
                    else
                        if !@host_item.active_warning_id.nil? or !@host_item.active_high_id.nil? or !@host_item.active_low_id.nil?
                            if !@host_item.active_low_id.nil?
                                ActiveAlert.find(@host_item.active_low_id).destroy
                            elsif !@host_item.active_warning_id.nil?
                                ActiveAlert.find(@host_item.active_warning_id).destroy
                            elsif !@host_item.active_high_id.nil?
                                ActiveAlert.find(@host_item.active_high_id).destroy
                            end
                            @host_item.update(active_low_id: nil)
                            @host_item.update(active_high_id: nil)
                            @host_item.update(active_warning_id: nil)
                        end
                    end
                end
            end
        end
    end
end