class AddYearToSpDesignationNumbers < ActiveRecord::Migration
  def self.up
    add_column :sp_designation_numbers, :year, :integer
    
    # Assigning YEAR from SpApplication
    ActiveRecord::Base.connection.select_all("SELECT * FROM sp_applications WHERE designation_number <> 0 AND designation_number IS NOT NULL AND person_id IS NOT NULL").each do |row|
      if row['project_id'] || row['preference1_id'] || row['preference2_id'] || row['preference3_id'] || row['preference4_id'] || row['preference5_id']
        unless project_id = row['project_id']
          if row['preference5_id']
            project_id = row['preference5_id']
          elsif row['preference4_id']
            project_id = row['preference4_id']
          elsif row['preference3_id']
            project_id = row['preference3_id']
          elsif row['preference2_id']
            project_id = row['preference2_id']
          elsif row['preference1_id']
            project_id = row['preference1_id']
          end
        end
        if ActiveRecord::Base.connection.select_values("select 1 from sp_designation_numbers WHERE designation_number = #{row['designation_number']} AND person_id = #{row['person_id']} AND project_id = #{project_id} AND `year` = #{row['year']}").length == 0
          ActiveRecord::Base.connection.update("UPDATE sp_designation_numbers SET year = #{row['year']} WHERE designation_number = #{row['designation_number']} AND person_id = #{row['person_id']} AND project_id = #{project_id} AND `year` is null limit 1")
        end
      end
    end
    
    # Assign YEAR = 2012 for nil years
    ActiveRecord::Base.connection.update("UPDATE sp_designation_numbers SET year = '2012' WHERE year is NULL OR year = ''")
  end

  def self.down
    remove_column :sp_designation_numbers, :year
  end
end
