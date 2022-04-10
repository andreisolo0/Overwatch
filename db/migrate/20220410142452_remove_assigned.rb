class RemoveAssigned < ActiveRecord::Migration[6.1]
  def change
    remove_column :hosts, :assigned_items_host
  end
end
