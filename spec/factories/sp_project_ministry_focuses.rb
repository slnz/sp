FactoryGirl.define do
  factory :sp_project_ministry_focus do
    association :project, factory: :sp_project
    association :ministry_focus 
  end
end
