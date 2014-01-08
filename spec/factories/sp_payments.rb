FactoryGirl.define do
  factory :sp_payment, class: 'SpPayment' do
    association :application
    payment_type 'String'
    amount 1
  end
end