class AddRolesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin , :boolean
    add_column :users, :regular_user , :boolean
    add_column :users, :viewer, :boolean
  end
end
