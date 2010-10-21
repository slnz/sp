# gather payment information from Applicant
class PaymentsController < ApplicationController
  layout nil
  
  # Allow applicant to edit payment
  # /applications/1/payment_page/edit
  # js: provide a partial to replace the answer_sheets page area
  # html: return a full page for editing reference independantly (after submission)
  def edit
    @payment = SpPayment.new
    @payment.application = @application
  end
  
  def create
    
  end
  
  def update
    head :ok
  end
  
  def staff_search
    @payment = SpPayment.new(params[:payment])
    if @payment.staff_first.strip.empty? || @payment.staff_last.strip.empty?
      render; return
    end
    @results = Staff.find(:all, :order => 'lastName, firstName', :conditions => ["firstName like ? AND lastName like ? and removedFromPeopleSoft <> 'Y'", @payment.staff_first+'%', @payment.staff_last+'%'])
  end

 private
  def setup
    @application = Application.find(params[:application_id])
  end  
end
