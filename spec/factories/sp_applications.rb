FactoryGirl.define do
  factory :sp_application, class: SpApplication do
    association :person
    association :project, factory: :sp_project
    year SpApplication.year
  end
end
