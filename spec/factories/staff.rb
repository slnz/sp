FactoryGirl.define do
  factory :staff do
    association :person
    accountNo '0000000'
  end
end