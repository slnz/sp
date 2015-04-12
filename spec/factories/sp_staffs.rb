FactoryGirl.define do
  factory :sp_staff do
    type 'String'
    year { SpApplication.year }
    sp_project nil
    association :person

    factory :sp_staff_pd do
      type 'PD'
    end
  end
end
