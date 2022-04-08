class AddDescriptionToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :description, :text
  end
end
