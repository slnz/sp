FactoryGirl.define do
  factory :sp_designation_number do
    sequence(:designation_number) { |n| "dn_#{n}" }
    year SpApplication.year
  end
end
