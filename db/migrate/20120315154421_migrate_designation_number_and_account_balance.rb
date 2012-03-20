class MigrateDesignationNumberAndAccountBalance < ActiveRecord::Migration
  def self.up
    SpDesignationNumber.connection.select_all("SELECT * FROM sp_applications WHERE designation_number <> 0 AND designation_number IS NOT NULL AND person_id IS NOT NULL").each do |row|
      
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
        # puts "PROJ:#{row['project_id']} PREF1:#{row['preference1_id']} PREF2:#{row['preference2_id']} PREF3:#{row['preference3_id']} PREF4:#{row['preference4_id']} PREF5:#{row['preference5_id']} = #{project_id}"
        
        SpDesignationNumber.connection.insert("INSERT INTO sp_designation_numbers (person_id, project_id, designation_number, account_balance, created_at, updated_at) VALUES ( #{row['person_id']}, #{project_id}, #{row['designation_number']}, #{row['account_balance'] || 0}, 'NOW()', 'NOW()')")
      end
    end
  end

  def self.down
    SpDesignationNumber.connection.execute("TRUNCATE sp_designation_numbers");
  end
end
