class AddRebootRequired < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :reboot_required, :boolean
  end
end
