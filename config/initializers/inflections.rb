ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /(.*focus)$/i, '\1es'
  inflect.singular /(.*focus)es$/i, '\1'
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
  inflect.uncountable %w( sp_staff project_staff staff )
end