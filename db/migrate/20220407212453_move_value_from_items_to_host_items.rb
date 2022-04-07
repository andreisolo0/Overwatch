class MoveValueFromItemsToHostItems < ActiveRecord::Migration[6.1]
  def change
    remove_column :items, :value
    add_column :host_items, :value, :string
  end
end
