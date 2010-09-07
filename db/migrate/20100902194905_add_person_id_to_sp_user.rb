class SpUser < ActiveRecord::Base
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
    # add_column :sp_users, :person_id, :integer
    SpUser.all.each do |sp_user|
      sp_user.update_attribute(:person_id, sp_user.user.try(:person).try(:id))
    end
  end

  def self.down
    remove_column :sp_users, :person_id
  end
end