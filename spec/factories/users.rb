FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "email#{n}@email.com" }
    plain_password 'String'
    plain_password_confirmation 'String'
  end

end
