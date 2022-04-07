class AddResultFieldToRemoteActionsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :remote_actions, :result_of_command, :text
  end
end
