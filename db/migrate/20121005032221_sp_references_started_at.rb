class SpReferencesStartedAt < ActiveRecord::Migration
  def self.up
    add_column :sp_references, :started_at, :datetime
  end

  def self.down
    remove_column :sp_references, :started_at
  end
end
