class RemoteAction < ApplicationRecord
    belongs_to :user
    validates :action_name, presence: true, uniqueness: true
    validates :command_or_script, presence: true
    validates :path_to_script, presence: true, :if => :script
end