class AddCommandMethodForItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :command_to_read, :string
  end
end
