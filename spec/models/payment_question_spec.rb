require 'spec_helper'

describe PaymentQuestion do
  before(:each) do
    @person = create(:person)
    @project = create(:sp_project)
    @application = create(:sp_application, person: @person, project: @project)
    @payment_question = PaymentQuestion.new
  end
  
  describe "when calling 'response' function" do
    it "should return a new payment if no application specified" do
      payment = SpPayment.new
      response = @payment_question.send(:response)
      response.should_not be nil
    end
    it "should return the existing application payment if the application already have payments" do
      payment = create(:sp_payment, application: @application)
      response = @payment_question.send(:response, @application).first
      response.id.should be payment.id
    end
    it "should return a new application payment if the application do not have payments yet" do
      response = @payment_question.send(:response, @application)
      response.should_not be nil
    end
  end
  
  describe "when calling 'display_response' function" do
    it "should return a blank string if no application specified" do
      @payment_question.should_receive(:response)
      response = @payment_question.send(:display_response)
      response.should == ''
    end
    it "should return an existing application payment string if the application already have payments" do
      payment = create(:sp_payment, application: @application)
      @payment_question.should_receive(:response).with(@application).and_return(payment)
      response = @payment_question.send(:display_response, @application)
      response.should == "#{payment.payment_type}: #{payment.amount}"
    end
    it "should return a blank string if the application do not have payments yet" do
      @payment_question.should_receive(:response).with(@application)
      response = @payment_question.send(:display_response, @application)
      response.should == ""
    end
  end
  
  #describe "when calling 'has_response' function" do
    #before(:each) do
      #question_sheet = create(:question_sheet)
      #answer_sheet = create(:answer_sheet)
      #answer_sheet_question_sheet = create(:answer_sheet_question_sheet, answer_sheet: answer_sheet, question_sheet: question_sheet)
    #end
    #it "should return a boolean 'false' if no application specified" do
      #response = @payment_question.send(:has_response?)
      #response.should be false
    #end
    #it "should return a boolean 'true' if the application already have payments" do
      #payment = create(:sp_payment, application: @application)
      #response = @payment_question.send(:has_response?, @application)
      #response.should be true
    #end
    #it "should return a boolean 'false' if the application do not have payments yet" do
      #response = @payment_question.send(:has_response?, @application)
      #response.should be false
    #end
  #end
end
