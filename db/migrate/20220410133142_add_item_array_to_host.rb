class AddItemArrayToHost < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :assigned_items_host, :string, array: true, default: []
  end
end
