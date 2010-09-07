class User < ActiveRecord::Base
  set_table_name 			"simplesecuritymanager_user"
	set_primary_key 		"userID"
	has_one :person, :foreign_key => 'fk_ssmUserID'	
end

class Person < ActiveRecord::Base 
  set_table_name   "ministry_person"
  set_primary_key  "personID"
end

class SpUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => :ssm_id
end
class SpNationalCoordinator < SpUser
end
class SpRegionalCoordinator < SpUser
end
class SpDirector < SpUser
end
class SpEvaluator < SpUser
end
class SpGeneralStaff < SpUser
end
class SpProjectStaff < SpUser
end

class AddPersonIdToSpUser < ActiveRecord::Migration
  def self.up
    add_column :sp_users, :person_id, :integer
    SpUser.all.each do |sp_user|
      sp_user.update_attribute(:person_id, sp_user.user.try(:person).try(:id))
    end
  end

  def self.down
    remove_column :sp_users, :person_id
  end
end