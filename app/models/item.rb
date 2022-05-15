class Item < ApplicationRecord
    has_many :host_items
    has_many :hosts, through: :host_items
    validates :item_name, presence: true, uniqueness: true
    validates :interval_to_read, presence: true
    validates :command_to_read, presence: true

end