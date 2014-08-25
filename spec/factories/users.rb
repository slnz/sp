FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "email#{n}@email.com" }
  end

end
