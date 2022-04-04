class CreateItemsModel < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :item_name
      t.string :value
      t.string :interval_to_read
      t.integer :user_id
      t.timestamps
    end
  end
end
