class AddAlertName < ActiveRecord::Migration[6.1]
  def change
    add_column :host_items, :alert_name_high, :string
    add_column :host_items, :alert_name_warning, :string
    add_column :host_items, :alert_name_low, :string
  end
end
