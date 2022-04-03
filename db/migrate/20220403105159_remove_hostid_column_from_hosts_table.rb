class RemoveHostidColumnFromHostsTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :hosts, :host_id
  end
end
