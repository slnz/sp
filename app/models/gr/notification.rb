class Gr::Notification
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(notification)
    @notification = notification.with_indifferent_access

    if @notification[:triggered_by] == 'us_infobase' && @notification['entity_type'] == 'person'
      begin
        @gr_person = GlobalRegistry::Entity.find(@notification[:id], 'filters[owned_by]' => @notification[:triggered_by])
        @gr_person = @gr_person['entity']['person']

        # We only want people from infobase if they have logins
        return false unless @gr_person['authentication'] && @gr_person['authentication']['relay_guid']

      rescue RestClient::Exception => e
        raise e.response.to_str
      end
      @person = find_or_initialize_person
      Person.transaction do
        update_person
        update_user
        update_email_addresses
        update_phone_numbers
      end
    end
  end

  def find_or_initialize_person
    cid = @notification[:client_integration_id]
    person = Person.find(cid) if cid
    person ||= Person.find_by(global_registry_id: @notification[:id])
    unless person
      user = User.find_by(globallyUniqueID: @gr_person['authentication']['relay_guid'])
      if user
        person = user.person
        user.destroy unless person
      end
    end
    person || Person.new
  end

  def update_person
    @person.first_name ||= @gr_person['first_name']
    @person.last_name ||= @gr_person['last_name']
    @person.account_no = @gr_person['account_number'] if @gr_person['account_number'].present?
    @person.isStaff = @gr_person['is_staff'] if @gr_person['is_staff'].present?
    @person.global_registry_id ||= @gr_person['id']
    @person.save!
  end

  def update_user
    user = @person.user || User.new
    user.username ||= @gr_person['username'] || @gr_person['authentication']['relay_guid']
    user.globallyUniqueID ||= @gr_person['authentication']['relay_guid']
    user.save!
    unless @person.user
      @person.user = user
      @person.save!
    end
  end

  def update_email_addresses
    return unless @gr_person['email_address']
    email_addresses = Array.wrap(@gr_person['email_address'])
    ea = email_addresses.detect { |e| e['primary'] }
    ea ||= email_addresses.first
    unless @person.email_addresses.where(email: ea['email'])
      @person.email_addresses.create!(email: ea['email'])
    end
  end

  def update_phone_numbers
    return unless @gr_person['phone_number']
    phone_numbers = Array.wrap(@gr_person['phone_number'])
    pn = phone_numbers.detect { |e| e['primary'] }
    pn ||= phone_numbers.first
    number = pn['number'].gsub(/[^0-9]/, '')
    unless @person.phone_numbers.detect { |p| p.number.gsub(/[^0-9]/, '') =~ /#{number}$/ }
      @person.phone_numbers.create!(number: number, location: pn['location'], extension: pn['extension'])
    end
  end
end
