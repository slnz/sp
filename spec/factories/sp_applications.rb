FactoryGirl.define do
  factory :sp_application do
    association :person
    association :project, factory: :sp_project
    year SpApplication.year
  end
end