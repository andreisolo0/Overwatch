class AddTriggerCollumnsToHostItemTable < ActiveRecord::Migration[6.1]
  def change
    add_column :host_items, :threshold_high, :string
    add_column :host_items, :threshold_warning, :string
    add_column :host_items, :threshold_low, :string
    add_column :host_items, :active_high_id, :string
    add_column :host_items, :active_warning_id, :string
    add_column :host_items, :active_low_id, :string
  end
end
