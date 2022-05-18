class AddResolvedAtToAlert < ActiveRecord::Migration[6.1]
  def change
    add_column :active_alerts, :resolved_at, :datetime
  end
end
