FactoryGirl.define do
  factory :country do
    sequence(:country) { |n| "Country#{n}" }
    sequence(:code) { |n| "Country#{n}" }
  end
end
