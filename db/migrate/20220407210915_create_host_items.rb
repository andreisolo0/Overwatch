class CreateHostItems < ActiveRecord::Migration[6.1]
  def change
    create_table :host_items do |t|
      t.references :host, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
