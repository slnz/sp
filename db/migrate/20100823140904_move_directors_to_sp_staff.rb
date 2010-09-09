class SpProject < ActiveRecord::Base
end
class SpProjectVersion < ActiveRecord::Base
end
class SpStaff < ActiveRecord::Base
  set_inheritance_column 'fake_column'
end
class SpApplication < ActiveRecord::Base
end

class MoveDirectorsToSpStaff < ActiveRecord::Migration
  def self.up
    remove_index :sp_staff, :name => 'project_staff_person'
    change_column :sp_staff, :type, :string, :limit => 100
    
    SpProject.all.each do |project|
      SpStaff.create(:person_id => project.pd_id, :project_id => project.id, :type => 'PD', :year => project.year) if project.pd_id.present? && project.pd_id != 0
      SpStaff.create(:person_id => project.apd_id, :project_id => project.id, :type => 'APD', :year => project.year) if project.apd_id.present? && project.apd_id != 0
      SpStaff.create(:person_id => project.opd_id, :project_id => project.id, :type => 'OPD', :year => project.year) if project.opd_id.present? && project.opd_id != 0
      SpStaff.create(:person_id => project.coordinator_id, :project_id => project.id, :type => 'Coordinator', :year => project.year) if project.coordinator_id.present? && project.coordinator_id != 0
    end
    
    SpProjectVersion.connection.select_all('select max(id) as id, sp_project_id, pd_id, apd_id, opd_id, coordinator_id, year from sp_project_versions where pd_id is not null group by year, sp_project_id').each do |row|
      next unless row['sp_project_id'].present?
      begin
        SpStaff.create(:person_id => row['pd_id'], :project_id => row['sp_project_id'], :type => 'PD', :year => row['year']) if row['pd_id'].present? && row['pd_id'] != 0 && !SpStaff.where(:person_id => row['pd_id'], :project_id => row['sp_project_id'], :type => 'PD', :year => row['year']).first
      rescue ActiveRecord::InvalidForeignKey; end
      begin
        SpStaff.create(:person_id => row['apd_id'], :project_id => row['sp_project_id'], :type => 'APD', :year => row['year']) if row['apd_id'].present? && row['apd_id'] != 0 && !SpStaff.where(:person_id => row['apd_id'], :project_id => row['sp_project_id'], :type => 'APD', :year => row['year']).first
      rescue ActiveRecord::InvalidForeignKey; end
      begin
        SpStaff.create(:person_id => row['opd_id'], :project_id => row['sp_project_id'], :type => 'OPD', :year => row['year']) if row['opd_id'].present? && row['opd_id'] != 0 && !SpStaff.where(:person_id => row['opd_id'], :project_id => row['sp_project_id'], :type => 'OPD', :year => row['year']).first
      rescue ActiveRecord::InvalidForeignKey; end
      begin
        SpStaff.create(:person_id => row['coordinator_id'], :project_id => row['sp_project_id'], :type => 'Coordinator', :year => row['year']) if row['coordinator_id'].present? && row['coordinator_id'] != 0 && !SpStaff.where(:person_id => row['coordinator_id'], :project_id => row['sp_project_id'], :type => 'Coordinator', :year => row['year']).first
      rescue ActiveRecord::InvalidForeignKey; end
    end
    add_index :sp_staff, [:project_id, :type, :year], :name => "project_staff_type"
    SpApplication.connection.update("update sp_applications set project_id = preference1_id where project_id is NULL")
  end

  def self.down
    remove_index :sp_staff, :name => :project_staff_type
    SpStaff.connection.execute("delete from sp_staff where type IN('PD', 'APD', 'OPD', 'Coordinator')")
    add_index :sp_staff, [:project_id, :person_id, :year], :unique => true, :name => 'project_staff_person'
  end
end