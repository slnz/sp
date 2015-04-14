Fe::Address.class_eval do
  self.table_name = 'ministry_newaddress'

  validates_presence_of :address_type

  before_save :stamp

  def stamp
    self.changed_by = ApplicationController.application_name
  end

  def display_html
    ret_val = address1 || ''
    ret_val += '<br/>' + address2 unless address2.nil? || address2.empty?
    ret_val += '<br/>' unless ret_val.empty?
    ret_val += city + ', ' unless city.nil? || city.empty?
    ret_val += state + ' ' unless state.nil?
    ret_val += zip unless zip.nil?
    ret_val += '<br/>' + country + ',' unless country.nil? || country.empty? || country == 'USA'
    ret_val
  end
  alias_method :to_s, :display_html

  def phone_number
    phone = (home_phone && !home_phone.empty?) ? home_phone : cell_phone
    phone = (phone && !phone.empty?) ? phone : work_phone
    phone
  end

  def phone_numbers
    unless @phone_numbers
      @phone_numbers = []
      @phone_numbers << home_phone + ' (home)' unless home_phone.blank?
      @phone_numbers << cell_phone + ' (cell)' unless cell_phone.blank?
      @phone_numbers << work_phone + ' (work)' unless work_phone.blank?
    end
    @phone_numbers
  end
end
