class RenameEmailColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :emails, :email
  end
end
