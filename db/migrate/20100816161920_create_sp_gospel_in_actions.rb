class SpGospelInAction < ActiveRecord::Base
end

class CreateSpGospelInActions < ActiveRecord::Migration
  def self.up
    # create_table :sp_gospel_in_actions do |t|
    #   t.string :name
    # 
    #   t.timestamps
    # end
    ['Orphan care', 
     'HIV/AIDS hospital, hostel, or hospice',
     'Street children',
     'Human trafficking',
     'Medical clinics',
     'Relief/Rebuilding'].each {|d| SpGospelInAction.create(:name => d)}
  end

  def self.down
    drop_table :sp_gospel_in_actions
  end
end
