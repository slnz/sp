class Gr::Notification
  def initialize(notification)
    @notification = notification
  end

  def handle_request
    if @notification[:triggered_by] == 'us_infobase' && @notification['entity_type'] == 'person'
      begin
        @gr_person = GlobalRegistry::Entity.find(@notification[:id], 'filters[owned_by]' => @notification[:triggered_by])
        @gr_person = @gr_person['entity']['person']
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
    return unless @gr_person['authentication']
    user = @person.user || @person.user.new
    user.username ||= @gr_person['username'] || @gr_person['authentication']['relay_guid']
    user.globallyUniqueID ||= @gr_person['authentication']['relay_guid']
    user.save!
  end

  def update_email_addresses
    return unless @gr_person['email_address']
    ea = @gr_person['email_address'].detect { |e| e['primary'] }
    ea ||= @gr_person['email_address'].first
    unless @person.email_addresses.where(email: ea['email'])
      @person.email_addresses.create!(email: ea['email'])
    end
  end

  def update_phone_numbers
    return unless @gr_person['phone_number']
    pn = @gr_person['phone_number'].detect { |e| e['primary'] }
    pn ||= @gr_person['phone_number'].first
    number = pn['number'].gsub(/[^0-9]/, '')
    unless @person.phone_numbers.detect { |p| p.number.gsub(/[^0-9]/, '') =~ /#{number}$/ }
      @person.phone_numbers.create!(number: number, location: ea['location'], extension: ea['extension'])
    end
  end
end
