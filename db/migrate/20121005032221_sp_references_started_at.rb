class SpReferencesStartedAt < ActiveRecord::Migration
  def up
    add_column :sp_references, :started_at, :datetime
  end

  def down
  end
end
