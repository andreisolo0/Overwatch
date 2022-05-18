class AddHostIdToAlert < ActiveRecord::Migration[6.1]
  def change
    add_column :active_alerts, :host_id, :int
  end
end
