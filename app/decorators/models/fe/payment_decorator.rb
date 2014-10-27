Fe::Payment.class_eval do
  belongs_to :answer_sheet, class_name: Fe.answer_sheet_class, :foreign_key => "application_id"

  def async_push_to_global_registry
    return unless application

    application.async_push_to_global_registry unless application.global_registry_id.present?

    super(application.global_registry_id, 'summer_project_application', application)
  end


  def self.push_structure_to_global_registry
    parent_id = GlobalRegistry::EntityType.get(
      {'filters[name]' => 'summer_project_application'}
    )['entity_types'].first['id']
    super(parent_id)
  end

  def self.global_registry_entity_type_name
    'summer_project_payment'
  end
end
