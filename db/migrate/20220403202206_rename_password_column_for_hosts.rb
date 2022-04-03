class RenamePasswordColumnForHosts < ActiveRecord::Migration[6.1]
  def change
    rename_column :hosts, :password_digest, :password
  end
end
