class UpdateMinistries < ActiveRecord::Migration
  def self.up
    change1 = Ministry.find_by_name('WSN')
    change1.update_attribute('name','Global Missions') if change1.present?

    change2 = Ministry.find_by_name('Student Venture')
    change2.update_attribute('name','Cru High School') if change2.present?
  end

  def self.down
    change1 = Ministry.find_by_name('Global Missions')
    change1.update_attribute('name','WSN') if change1.present?

    change2 = Ministry.find_by_name('Cru High School')
    change2.update_attribute('name','Student Venture') if change2.present?
  end
end
