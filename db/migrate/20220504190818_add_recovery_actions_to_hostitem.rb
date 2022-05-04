class AddRecoveryActionsToHostitem < ActiveRecord::Migration[6.1]
  def change
    add_column :host_items, :recovery_high, :int
    add_column :host_items, :recovery_warning, :int
    add_column :host_items, :recovery_low, :int
  end
end
