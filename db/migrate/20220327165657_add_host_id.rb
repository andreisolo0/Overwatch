class AddHostId < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :host_id, :int
  end
end
