# ReferenceQuestion
# - a question that provides a fields to specify a reference

class PaymentQuestion < Question
  
  def response(app=nil)
    return SpPayment.new unless app
    app.payments || [SpPayment.new(:application_id => app.id) ]
  end
  
  def display_response(app=nil)
    return response(app).to_s
  end
  
  def has_response?(answer_sheet = nil)
    if answer_sheet
      answer_sheet.payments.length > 0
    else
      SpPayment.count > 0
    end
  end
  
end

