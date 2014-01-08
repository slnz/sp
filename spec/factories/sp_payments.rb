FactoryGirl.define do
  factory :payment, class: 'SpPayment' do
    association :application
    payment_type 'String'
    amount 1
  end
end