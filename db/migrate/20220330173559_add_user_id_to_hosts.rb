class AddUserIdToHosts < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :user_id, :int
  end
end
