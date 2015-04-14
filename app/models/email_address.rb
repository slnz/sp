require 'validates_email_format_of'
class EmailAddress < Fe::EmailAddress
  include CruLib::GlobalRegistryMethods
  include Sidekiq::Worker
  belongs_to :person

  def async_push_to_global_registry(parent_id = nil, parent_type = 'person')
    return unless person

    person.async_push_to_global_registry unless person.global_registry_id.present?
    parent_id = person.global_registry_id unless parent_id

    super(parent_id, parent_type, person)
  end

  def self.columns_to_push
    super
    @columns_to_push + [{ name: 'email', type: 'email' }]
  end

  def self.push_structure_to_global_registry
    parent_id = GlobalRegistry::EntityType.get(
        'filters[name]' => 'person'
    )['entity_types'].first['id']
    super(parent_id)
  end

  def self.skip_fields_for_gr
    %w(id email created_at updated_at global_registry_id person_id)
  end

  def merge(other)
    EmailAddress.transaction do
      if updated_at && other.primary? && other.updated_at > updated_at
        person.email_addresses.collect { |e| e.update_attribute(:primary, false) }
        new_primary = person.email_addresses.detect { |e| e.email == other.email }
        new_primary.update_attribute(:primary, true) if new_primary
      end
      begin
        MergeAudit.create!(mergeable: self, merge_loser: other)
      rescue ActiveRecord::RecordNotFound
        # ???
      end
      other.reload
      GlobalRegistry::Entity.delete_or_ignore(other.global_registry_id) if other.global_registry_id
      other.destroy
    end
  end
end
