class AddPingToHosts < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :online, :boolean
  end
end
