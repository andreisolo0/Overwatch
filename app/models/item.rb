class Item < ApplicationRecord
    has_many :host_items
    has_many :hosts, through: :host_items
end