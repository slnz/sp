def get_options(id)
  options = []
  ActiveRecord::Base.connection.select_all("select * from sp_question_options where question_id = #{id} order by position, `option`").each do |opt|
    if opt["value"] == opt["option"]
      options << opt["value"]
    else
      options << "#{opt['value']};#{opt['option']}"
    end
  end
  options.join("\n")
end
class MigrateSpToNewQe < ActiveRecord::Migration
  def self.up
    # questionnaires
    # ActiveRecord::Base.connection.delete("truncate sp_question_sheets")
    # ActiveRecord::Base.connection.select_all("select id, title from questionnaires where type = 'SpQuestionnaire'").each do |row|
    #   ActiveRecord::Base.connection.insert("insert into sp_question_sheets(id, label) VALUES(#{row['id']}, '#{row['title']}')")
    # end
    # 
    # ActiveRecord::Base.connection.delete("truncate sp_pages")
    # ActiveRecord::Base.connection.select_all("select page_id, questionnaire_id, position from sp_questionnaire_pages").each do |row|
    #   ActiveRecord::Base.connection.insert("insert into sp_pages(id, question_sheet_id, number, label) VALUES(#{row['page_id']}, #{row['questionnaire_id']}, #{row['position']}, '')")
    # end
    # 
    # ActiveRecord::Base.connection.select_all("select id, title, hidden from sp_pages_deprecated").each do |row|
    #   ActiveRecord::Base.connection.update("update sp_pages set label = '#{row['title']}', hidden = #{row['hidden'].to_i} where id = #{row['id']}")
    # end
    # 
    # ActiveRecord::Base.connection.delete("truncate sp_page_elements")
    # ActiveRecord::Base.connection.select_all("select page_id, element_id, position, created_at, updated_at from sp_page_elements_deprecated").each do |row|
    #   ActiveRecord::Base.connection.insert("insert into sp_page_elements(page_id, element_id, position, created_at, updated_at) VALUES(#{row['page_id']}, #{row['element_id']}, #{row['position']}, '#{row['created_at'].to_s(:db)}', '#{row['updated_at'].to_s(:db)}')")
    # end
    # change_column :sp_elements, :label, :text
    ActiveRecord::Base.connection.delete("truncate sp_elements")
    ActiveRecord::Base.connection.select_all("select * from sp_elements_deprecated").each do |row|
      kind = ''
      style = ''
      options = ''
      label = row['text']
      case row['type']
      when 'Instruction'
        kind = 'Paragraph'
        style = 'paragraph'
        label = ''
        options = row['text']
      when 'Heading'
        kind = 'Section'
        style = 'section'
      when 'Textfield'
        kind = 'TextField'
        style = 'short'
      when 'YesNo'
        kind = 'ChoiceField'
        style = 'yes-no'
        options = "1;Yes\n0;No"
      when 'Selectfield'
        kind = 'ChoiceField'
        style = 'drop-down'
        options = get_options(row['id'])
      when 'Radiofield'
        kind = 'ChoiceField'
        style = 'radio'
        options = get_options(row['id'])
      when 'Group'
        kind = 'QuestionGrid'
        style = 'grid'
      when 'Multicheckbox'
        kind = 'ChoiceField'
        style = 'checkbox'
        # We need to collect all the options
        options = ActiveRecord::Base.connection.select_values("select text from sp_elements_deprecated where parent_id = #{row['id']} order by position").join("\n")
      when 'Checkboxfield'
        next
      when 'Textarea'
        kind = 'TextField'
        style = 'essay'
      when 'Datefield'
        kind = 'DateField'
        style = 'date'
      when 'Statefield'
        kind = 'StateChooser'
        style = 'state_chooser'
      when 'SpPeerReference'
        kind = 'Reference'
        style = 'peer'
      when 'SpSpiritualReference1','SpSpiritualReference2'
        kind = 'Reference'
        style = 'spiritual'
      when 'SpParentReference'
        kind = 'Reference'
        style = 'parent'
      else
        kind = row['type']
        style = kind.downcase
      end
      object = case row['question_table']
               when 'answers' then ''
               else row['question_table']
               end
      ActiveRecord::Base.connection.insert("insert into sp_elements(id, kind, style, label, content, required, position, is_confidential, 
                                                                    object_name, attribute_name, question_grid_id, created_at, updated_at) 
                                            VALUES(#{row['id']}, '#{kind}', '#{style}', #{ActiveRecord::Base.quote_value(label)}, #{ActiveRecord::Base.quote_value(options)}, #{row['is_required'].to_i}, #{row['position'].to_i}, 
                                            #{row['is_confidential'].to_i}, '#{object}', '#{row['question_column']}', #{row['parent_id'] || 'NULL'}, 
                                            '#{(row['created_at'] || Time.now).to_s(:db)}', '#{(row['updated_at'] || Time.now).to_s(:db)}')")
    end
    
  end

  def self.down
    # change_column :sp_elements, :label, :string
  end
end