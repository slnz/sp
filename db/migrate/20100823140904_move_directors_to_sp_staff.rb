class SpProject < ActiveRecord::Base
end
class SpProjectVersion < ActiveRecord::Base
end

class MoveDirectorsToSpStaff < ActiveRecord::Migration
  def self.up
    remove_index :sp_staff, :name => 'project_staff_person'
    SpProject.all.each do |project|
      SpStaff.create(:person_id => project.pd_id, :project_id => project.id, :type => 'PD', :year => project.year) if project.pd_id.present?
      SpStaff.create(:person_id => project.apd_id, :project_id => project.id, :type => 'APD', :year => project.year) if project.apd_id.present?
      SpStaff.create(:person_id => project.opd_id, :project_id => project.id, :type => 'OPD', :year => project.year) if project.opd_id.present?
      SpStaff.create(:person_id => project.coordinator_id, :project_id => project.id, :type => 'Coordinator', :year => project.year) if project.coordinator_id.present?
    end
    
    SpProjectVersion.connection.select_all('select max(id) as id, sp_project_id, /bin/bash: year: command not found from sp_project_versions group by /bin/bash: year: command not found, sp_project_id').each do |row|
      next unless row['sp_project_id'].present?
      project = SpProjectVersion.find(row['id'])
      if project
        SpStaff.create(:person_id => project.pd_id, :project_id => row['sp_project_id'], :type => 'PD', :year => row['year']) if row['pd_id'].present?
        SpStaff.create(:person_id => project.apd_id, :project_id => row['sp_project_id'], :type => 'APD', :year => row['year']) if row['apd_id'].present?
        SpStaff.create(:person_id => project.opd_id, :project_id => row['sp_project_id'], :type => 'OPD', :year => row['year']) if row['opd_id'].present?
        SpStaff.create(:person_id => project.coordinator_id, :project_id => row['sp_project_id'], :type => 'Coordinator', :year => row['year']) if row['coordinator_id'].present?
      end
    end
    add_index :sp_staff, [:project_id, :type, :year], :name => "project_staff_type"
  end

  def self.down
    remove_index :sp_staff, :name => :project_staff_type
    SpStaff.connection.execute("delete from sp_staff where type IN('PD', 'APD', 'OPD', 'Coordinator')")
    add_index :sp_staff, [:project_id, :person_id, :year], :unique => true, :name => 'project_staff_person'
  end
end