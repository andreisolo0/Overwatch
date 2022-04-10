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

    
end