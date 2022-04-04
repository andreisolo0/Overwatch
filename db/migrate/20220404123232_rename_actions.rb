class RenameActions < ActiveRecord::Migration[6.1]
  def change
    rename_table :actions, :remote_actions
  end
end
