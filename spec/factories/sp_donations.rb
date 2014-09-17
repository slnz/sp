FactoryGirl.define do
  factory :sp_donation do
    sequence(:amount) {|n| n * 100 }
  end
end
