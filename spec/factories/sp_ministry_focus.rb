FactoryGirl.define do
  factory :sp_ministry_focus do
    sequence(:name) { |n| "ministry_focus_name_#{n}" }
  end
end
