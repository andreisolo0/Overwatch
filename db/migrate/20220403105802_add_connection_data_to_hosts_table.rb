class AddConnectionDataToHostsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :user_to_connect, :string
    add_column :hosts, :password_digest, :string
    add_column :hosts, :ssh_port, :int
    add_column :hosts, :run_as_sudo, :boolean
    add_column :hosts, :os, :string
  end
end
