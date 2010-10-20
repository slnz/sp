class MigrateReferences < ActiveRecord::Migration
  def self.up
    remove_column :sp_references, :response_id
    remove_column :sp_references, :answer_sheet_id
    remove_column :sp_references, :question_id
    rename_table :sp_references, :sp_references_deprecated
    create_table ReferenceSheet.table_name do |t|
      t.integer :question_id, :applicant_answer_sheet_id
      t.datetime :email_sent_at
      t.string :relationship
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :status
      t.datetime :submitted_at
      t.string :access_key
    
      t.timestamps
    end
    # ReferenceSheet.connection.execute('truncate sp_references');
    ReferenceSheet.connection.select_all("select * from sp_references_deprecated").each do |row|
      question_id = case row['type']
                    when 'SpPeerReference'
                      236
                    when 'SpSpiritualReference1'
                      237
                    when 'SpSpiritualReference2'
                      238
                    when 'SpParentReference'
                      425
                    end
                    
      ReferenceSheet.connection.insert("insert into sp_references(question_id, applicant_answer_sheet_id, email_sent_at, relationship, title, first_name,
                                        last_name, phone, email, status, submitted_at, access_key, created_at, updated_at) 
                                        VALUES(#{question_id}, #{row['application_id']}, '#{row['email_sent_at']}', '', '#{row['title']}', 
                                        '#{ActiveRecord::Base.connection.quote_string(row['first_name'].to_s)}',
                                        '#{ActiveRecord::Base.connection.quote_string(row['last_name'].to_s)}', 
                                        '#{ActiveRecord::Base.connection.quote_string(row['phone'].to_s)}', 
                                        '#{ActiveRecord::Base.connection.quote_string(row['email'].to_s)}', 
                                        '#{row['status']}', '#{row['submitted_at']}', 
                                        '#{row['access_key']}', '#{row['created_at']}', '#{row['updated_at']}')")
    end
  end

  def self.down
    drop_table ReferenceSheet.table_name
    rename_table :sp_references_deprecated, :sp_references
    add_column :sp_references, :question_id, :integer
    add_column :sp_references, :answer_sheet_id, :integer
    add_column :sp_references, :response_id, :integer
  end
end