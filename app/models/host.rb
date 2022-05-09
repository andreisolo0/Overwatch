class Host < ApplicationRecord
    belongs_to :user
    has_many :host_items
    has_many :items, through: :host_items
    
    def online?
        Host.find(self.id).online
        # read the online status from the host table
    end

    def init?
        Host.find(self.id).os.nil? 
    end

    def self.search(search)
        if search
            host = Host.find_by(hostname: search)
            if host
                self.where(hostname: host.hostname)
            else
                @hosts = Host.all
            end
        else
            @hosts = Host.all
        end

    end
end