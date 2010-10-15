class MigrateSpAnswers < ActiveRecord::Migration
  def self.up
    remove_index :sp_answers, :short_value
    unless ActiveRecord::Base.connection.select_value("select count(id) from sp_answers_deprecated").to_i == ActiveRecord::Base.connection.select_value("select count(id) from sp_answers").to_i
      ActiveRecord::Base.connection.delete("truncate sp_answers")
      ActiveRecord::Base.connection.execute('insert into sp_answers (id, answer_sheet_id, question_id, value) select id, instance_id, question_id, answer from sp_answers_deprecated')
    end
    total = ActiveRecord::Base.connection.select_value("select max(id) from sp_answers_deprecated").to_i
    count = 0
    while count < total
      ActiveRecord::Base.connection.select_all("select * from sp_answers where id >= #{count} and id < #{count + 10000}").each do |row|
        # question_sheet_id = questions[row['question_id'].to_i]
        value = row['value'].to_s
        if value.length > 225
          short_value = value[0..221] + '...'
        else
          short_value = value
        end
        ActiveRecord::Base.connection.execute("update sp_answers set short_value = '#{ActiveRecord::Base.connection.quote_string(short_value)}' where id = #{row['id']}") unless value == short_value
      end
      count += 10000
    end
    add_index :sp_answers, :short_value
  end

  def self.down
    
  end
end