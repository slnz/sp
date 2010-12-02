# gather payment information from Applicant
class PaymentsController < ApplicationController
  prepend_before_filter :ssm_login_required, :except => [:edit, :update]
  prepend_before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter, :only => [:edit, :update]
  before_filter :setup
  
  # Allow applicant to edit payment
  # /applications/1/payment_page/edit
  # js: provide a partial to replace the answer_sheets page area
  def edit
    @payment = SpPayment.find(params[:id])
    @application = @payment.application    
    # if this isn't a staff payment they shouldn't be here for this staff person
    unless 'Staff' == @payment.payment_type && current_person.isStaff?
      render('no_access') and return
    end
    @payment.status = "Approved" # set the status so a default radio button will be selected
  end

  def create
    SpPayment.transaction do
      @payment = SpPayment.new(params[:payment])
      if @application.payments.non_denied.length > 0
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
                                    {'error' => "Credit card transaction failed: #{response.message} \n #{response.inspect} \n #{creditcard.inspect}"})
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
  end
  
  def update
    @payment = SpPayment.includes({:application => :person}).find(params[:id])
    @application = @payment.application
    @person = @application.person
    @payment.status = params[:payment][:status]
    staff_approval
    @payment.save!
    staff_payment_processed_email(@payment)
    @payment.application.complete
  end

  def approve
    @payment = SpPayment.find(params[:id])
    @payment.auth_code = sp_user.user.person.accountNo
    case @payment.payment_type
    when 'Staff'
      staff_approval
      staff_payment_processed_email(@payment)
    when 'Mail'
      Notifier.notification(@application.email, # RECIPIENTS
                            "gosummerproject@uscm.org", # FROM
                            "Check Received", # LIQUID TEMPLATE NAME
                            {'name' => @application.name}).deliver
    end
    @payment.approve!
    @payment.application.complete
  end

  def staff_search
    @payment = @application.payments.new(params[:payment])
    if @payment.staff_first.strip.empty? || @payment.staff_last.strip.empty?
      render; return
    end
    @results = Staff.find(:all, :order => 'lastName, firstName', :conditions => ["(firstName like ? OR preferredName like ?) AND lastName like ? and removedFromPeopleSoft <> 'Y'", @payment.staff_first+'%', @payment.staff_first+'%', @payment.staff_last+'%'])
  end
  
  def destroy
    @payment = @application.payments.find(params[:id])
    @payment.destroy
  end

  private
    def setup
      if sp_user && sp_user.can_su_application?
        @application = SpApplication.find(params[:application_id])
      else
        @application = current_person.sp_applications.find(params[:application_id])
      end
    end
  
    def send_staff_payment_request(payment)
      @person = @application.person
      staff = Staff.find_by_accountNo(payment.payment_account_no)
      raise "Invalid staff payment request: " + payment.inspect if staff.nil?
      Notifier.notification(staff.email, # RECIPIENTS
                                    "gosummerproject@uscm.org", # FROM
                                    "Staff Payment Request", # LIQUID TEMPLATE NAME
                                    {'staff_full_name' => staff.informal_full_name, # HASH OF VALUES FOR REPLACEMENT IN LIQUID TEMPLATE
                                     'applicant_full_name' => @person.informal_full_name, 
                                     'applicant_email' => @person.email, 
                                     'applicant_home_phone' => @person.current_address.homePhone, 
                                     'payment_request_url' => url_for(:action => :edit, :application_id => @application.id, :id => @payment.id)},
                                     {:format => :html}).deliver
    end
    
    def staff_approval
      @payment.auth_code = current_person.accountNo
      if @payment.status == "Other Account"
        @payment.payment_account_no = params[:other_account]
        @payment.approve!
      end
    end
    
    def staff_payment_processed_email(payment)
      # Send appropriate email
      if payment.approved?
        # Send receipt to applicant
        Notifier.notification(@application.email, # RECIPIENTS
                              "gosummerproject@uscm.org", # FROM
                              "Applicant Staff Payment Receipt", # LIQUID TEMPLATE NAME
                              {'applicant_full_name' => @person.informal_full_name}).deliver
        # Send notice to Tool Owner
        Notifier.notification("gosummerproject@uscm.org", # RECIPIENTS - HARD CODED!
                              "help@campuscrusadeforchrist.com", # FROM
                              "Tool Owner Payment Confirmation", # LIQUID TEMPLATE NAME
                              {'payment_amount' => "$" + @payment.amount.to_s,
                               'payment_account_no' => @payment.payment_account_no,
                               'payment_auth_code' => @payment.auth_code,
                               'payment_id' => @payment.id}).deliver
      else
        # Sent notice to applicant that payment was declined
        Notifier.notification(@application.email, # RECIPIENTS
                              "gosummerproject@uscm.org", # FROM
                              "Payment Refusal", # LIQUID TEMPLATE NAME
                              {'applicant_full_name' => @person.informal_full_name}).deliver
      end
    end
end
