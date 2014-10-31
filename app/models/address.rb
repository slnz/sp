class Address < Fe::Address
  include CruLib::GlobalRegistryMethods
  include Sidekiq::Worker

  belongs_to :person

  def async_push_to_global_registry(parent_id = nil, parent_type = 'person')
    return unless person

    person.async_push_to_global_registry unless person.global_registry_id.present?
    parent_id = person.global_registry_id unless parent_id

    attributes_to_push['line1'] = address1
    attributes_to_push['line2'] = address2
    attributes_to_push['line3'] = address3
    attributes_to_push['line4'] = address4
    attributes_to_push['postal_code'] = zip
    super(parent_id, parent_type, person)
  end

  def self.push_structure_to_global_registry
    parent_id = GlobalRegistry::EntityType.get(
      {'filters[name]' => 'person'}
    )['entity_types'].first['id']
    super(parent_id)
  end

  def self.columns_to_push
    super
    @columns_to_push + [{ name: 'line1', type: 'string' },
                        { name: 'line2', type: 'string' },
                        { name: 'line3', type: 'string' },
                        { name: 'line4', type: 'string' },
                        { name: 'postal_code', type: 'string' }]
  end

  def self.skip_fields_for_gr
    super + %w(address_id address1 address2 address3 address4 home_phone work_phone cell_phone fax skype email url date_created date_changed created_by changed_by fk_person_id email2 start_date end_date facebook_link myspace_link title preferred_phone phone1_type phone2_type phone3_type)
  end

  def self.global_registry_entity_type_name
    'address'
  end
end
