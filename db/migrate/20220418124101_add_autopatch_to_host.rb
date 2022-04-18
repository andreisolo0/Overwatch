class AddAutopatchToHost < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :autopatch, :boolean
  end
end
