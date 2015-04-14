class Address < Fe::Address
  include CruLib::GlobalRegistryMethods
  include Sidekiq::Worker

  sidekiq_options unique: true
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
      'filters[name]' => 'person'
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
    super + %w(address_id address1 address2 address3 address4 home_phone work_phone cell_phone fax skype email url date_created date_changed created_by changed_by person_id email2 start_date end_date facebook_link myspace_link title preferred_phone phone1_type phone2_type phone3_type)
  end

  def self.global_registry_entity_type_name
    'address'
  end

  def merge(other)
    Address.transaction do
      # We're only interested if the other address has been updated more recently
      if other.updated_at && updated_at && other.updated_at > updated_at
        # if any part of they physical address is there, copy all of it
        physical_address = %w(address1 address2 address3 address4 city state zip country)
        if other.attributes.slice(*physical_address).any? { |_k, v| v.present? }
          other.attributes.slice(*physical_address).each do |k, v|
            self[k] = v
          end
        end
        # Now copy the rest as long as they're not blank
        other_attributes = other.attributes.except(*(%w(id created_at person_id) + physical_address))
        attributes.each do |k, v|
          next if v == other_attributes[k]
          self[k] = case
                    when other_attributes[k].blank? then v
                    when v.blank? then other_attributes[k]
                    else
                      other.updated_at > updated_at ? other_attributes[k] : v
                    end
        end
        self['changed_by'] = 'MERGE'
      end
      MergeAudit.create!(mergeable: self, merge_loser: other)
      other.reload
      GlobalRegistry::Entity.delete(other.global_registry_id) if other.global_registry_id
      other.destroy
      save(validate: false)
    end
  end
end
