module HostHelper
    def assigned_items_for_current_host(host_id)
        
        @assigned_items = Array.new
        #https://stackoverflow.com/questions/12718759/ruby-on-rails-caching-variables
        #https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
        #Use Rails cache to fecth the data only when needed
        #@assigned_items=Rails.cache.fetch("assigned_items_for_host_#{host_id}") do
        
        Host.find(host_id).assigned_items_host.each do |assigned_item| @assigned_items<< [assigned_item, Item.find(assigned_item).item_name] end
       
       @assigned_items
   end


   def not_assigned_items_for_current_host(host_id)
        
    @not_assigned_items = Array.new
    
    Item.where.not(id: Host.find(host_id).assigned_items_host).each do |item| @not_assigned_items<<[item.id, item.item_name]  
        end

    @not_assigned_items
   end

   def jobs_to_schedule(host_id)
       
       @jobs_to_schedule = Array.new
       #https://stackoverflow.com/questions/12718759/ruby-on-rails-caching-variables
       #https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
       #Use Rails cache to fecth the data only when needed
       #@assigned_items=Rails.cache.fetch("assigned_items_for_host_#{host_id}") do
       @jobs_to_schedule=Rails.cache.fetch("jobs_to_schedule_for_host_#{host_id}") do
            scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))  
            
            Host.find(host_id).assigned_items_host.each do |assigned_item| 
                job_name="job_for_item_" + assigned_item.to_s + "_on_host_" + host_id.to_s
                
                if !scheduler_data.include?(job_name) 
                    @jobs_to_schedule << [assigned_item, Item.find(assigned_item).item_name]
                     
                end
            end
            #byebug
            @jobs_to_schedule
        end
   end

   def jobs_scheduled?(host_id,item_id)
    
    @job_scheduled=Rails.cache.fetch("job_scheduled_for_item_#{item_id}_host_#{host_id}") do
        scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'))) 
        job_name="job_for_item_" + item_id.to_s + "_on_host_" + host_id.to_s
        @job_scheduled=scheduler_data.include?(job_name) 
        @job_scheduled
    end
    
   end


    
end