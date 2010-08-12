class ChangeHousingCapacityToMaxAcceptedOnSpProject < ActiveRecord::Migration
  def self.up
    rename_column :sp_projects, :housing_capacity_men, :max_accepted_men
    rename_column :sp_projects, :housing_capacity_women, :max_accepted_women
  end

  def self.down
    rename_column :sp_projects, :max_accepted_men, :housing_capacity_men
    rename_column :sp_projects, :max_accepted_women, :housing_capacity_women
  end
end
