FactoryGirl.define do
  factory :sp_staff do
    type 'String'
    year { SpApplication.year }
    project nil
    person nil
  end
end
