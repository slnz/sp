class MergeAudit < ActiveRecord::Base
  belongs_to :mergeable, polymorphic: true
  belongs_to :merge_loser, polymorphic: true
end
