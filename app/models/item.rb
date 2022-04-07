class Item < ApplicationRecord
    belongs_to :host
    has_many :host_items
    has_many :hosts, through: :host_items
end