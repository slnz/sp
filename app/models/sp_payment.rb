class SpPayment < ActiveRecord::Base

  attr_accessor :first_name, :last_name, :address, :city, :state, :zip, :card_number,
                :expiration_month, :expiration_year, :security_code, :staff_first, :staff_last, :card_type

  belongs_to :application, :class_name => 'SpApplication', :foreign_key => 'application_id'
  
  after_save :check_app_complete
  
  def validate
    if credit?
      errors.add_on_empty([:first_name, :last_name, :address, :city, :state, :zip, :card_number,
                :expiration_month, :expiration_year, :security_code])
      errors.add(:card_number, "is invalid.") if get_card_type.nil?
    end
  end
  
  def check_app_complete
    if self.approved?
      self.application.complete
    end
  end
  
  def credit?
    self.payment_type == 'Credit Card'
  end
  
  def staff?
    self.payment_type == 'Staff'
  end
  
  def approved?
    self.status == "Approved"
  end
  
  def approve!
    self.status = "Approved"
    self.auth_code = card_number[-4..-1]
    self.save!
  end

  def get_card_type
    card =  ActiveMerchant::Billing::CreditCard.new(:number => card_number)
    card.valid?
    card.type
  end
  
  def to_s
    payment_type.present? ? payment_type + ': ' + amount.to_s : ''
  end
end
