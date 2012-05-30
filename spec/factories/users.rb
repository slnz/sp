FactoryGirl.define do
  factory :user do
    username 'email@email.com'
    plain_password 'String'
    plain_password_confirmation 'String'
  end
end
