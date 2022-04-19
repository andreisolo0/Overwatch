class CreateActiveAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :active_alerts do |t|
      t.string :host_item_id
      t.string :item_id
      t.string :threshold
      t.string :severity
      t.timestamps
    end
  end
end
