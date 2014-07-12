class Team < ActiveRecord::Base
  self.table_name  = "ministry_locallevel"
  self.primary_key = "teamID"

  has_many :team_members, :foreign_key => "teamID"
  has_many :people, -> { order(Person.table_name + ".lastName") }, :through => :team_members
  has_many :activities, :foreign_key => 'fk_teamID', :primary_key => "teamID"
  has_many :target_areas, -> { order("name") }, :through => :activities

  scope :active, -> { where("isActive = 'T'") }
  scope :from_region, lambda {|region| active.where("region = ? or hasMultiRegionalAccess = 'T'", region).order(:name)}

  def to_s() name; end
end
