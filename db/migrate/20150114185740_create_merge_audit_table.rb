class CreateMergeAuditTable < ActiveRecord::Migration
  def change
    create_table :merge_audits do |t|
      t.integer :mergeable_id
      t.string :mergeable_type
      t.integer :merge_loser_id
      t.string :merge_loser_type
    end
  end
end
