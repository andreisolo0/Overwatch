class AddAssigned < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :assigned_items_host, :int, array: true, default: []
  end
end
