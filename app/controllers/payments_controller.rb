# gather payment information from Applicant
class PaymentsController < ApplicationController
  layout nil
  before_filter :setup
  
  # Allow applicant to edit payment
  # /applications/1/payment_page/edit
  # js: provide a partial to replace the answer_sheets page area
  # html: return a full page for editing reference independantly (after submission)
  def edit
    @payment = SpPayment.new
    @payment.application = @application
  end
  
  def create
    @payment = SpPayment.new(params[:payment])
    if @application.payments.length > 0
      @payment.errors.add_to_base("You have already submitted a payment for this application.")
      render :action => "error.rjs"
    else
      @payment.amount = SpApplication.cost
      @payment.application_id = @application.id
      @payment.status = 'Pending'
      if @payment.valid?
        case @payment.payment_type
        when "Credit Card"
          card_type = params[:payment][:card_type]
          
          creditcard = ActiveMerchant::Billing::CreditCard.new(
            :type       => card_type,
            :number     => @payment.card_number,
            :month      => @payment.expiration_month,
            :year       => @payment.expiration_year,
            :verification_value => @payment.security_code,
            :first_name => @payment.first_name,
            :last_name  => @payment.last_name
          )   
          
          if creditcard.valid?
            response = GATEWAY.purchase(@payment.amount * 100, creditcard)
        
            if response.success?
              @payment.approve!
              # TODO: Send notification email
            else
              @payment.errors.add_to_base("Credit card transaction failed: #{response.message}")
              #Send email this way instead of raising error in order to still give an error message to user.
              Notifier.deliver_notification('programmers@cojourners.com', # RECIPIENTS
                                  "sp_error@uscm.org", # FROM
                                  "Credit Card Error", # LIQUID TEMPLATE NAME
                                  {'error' => "Credit card transaction failed: #{response.message}"})
            end
          else
            @payment.errors.add(:card_number, "is invalid.  Check the number and/or the expiration date.")
          end
        when "Mail"
          @payment.save
        when "Staff"
          @payment.save
          send_staff_payment_request(@payment)
        end
      end
    end
  end
  
  def update
    head :ok
  end
  
  def staff_search
    @payment = @application.payments.new(params[:payment])
    if @payment.staff_first.strip.empty? || @payment.staff_last.strip.empty?
      render; return
    end
    @results = Staff.find(:all, :order => 'lastName, firstName', :conditions => ["firstName like ? AND lastName like ? and removedFromPeopleSoft <> 'Y'", @payment.staff_first+'%', @payment.staff_last+'%'])
  end
  
  def destroy
    @payment = @application.payments.find(params[:id])
    @payment.destroy
  end

 private
  def setup
    @application = current_person.sp_applications.find(params[:application_id])
  end  
  
  def send_staff_payment_request(payment)
    @person = @application.person
    staff = Staff.find_by_accountNo(payment.payment_account_no)
    raise "Invalid staff payment request: " + payment.inspect if staff.nil?
    Notifier.deliver_notification(staff.email, # RECIPIENTS
                                  "gosummerproject@uscm.org", # FROM
                                  "Staff Payment Request", # LIQUID TEMPLATE NAME
                                  {'staff_full_name' => staff.informal_full_name, # HASH OF VALUES FOR REPLACEMENT IN LIQUID TEMPLATE
                                   'applicant_full_name' => @person.informal_full_name, 
                                   'applicant_email' => @person.email, 
                                   'applicant_home_phone' => @person.current_address.homePhone, 
                                   'payment_request_url' => url_for(:action => :edit, :application_id => @application.id, :id => @payment.id)})
  end
end
