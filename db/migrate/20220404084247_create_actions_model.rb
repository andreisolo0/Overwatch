class CreateActionsModel < ActiveRecord::Migration[6.1]
  def change
    create_table :actions do |t|
        t.string :action_name
        t.text :command_or_script
        t.text :path_to_script
        t.boolean :script
        t.integer :user_id
        t.timestamps
    end
  end
end
