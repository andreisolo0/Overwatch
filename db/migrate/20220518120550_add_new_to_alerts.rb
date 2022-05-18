class AddNewToAlerts < ActiveRecord::Migration[6.1]
  def change
    add_column :active_alerts, :new, :boolean, default: true
    add_column :active_alerts, :resolved, :boolean, default: false
  end
end