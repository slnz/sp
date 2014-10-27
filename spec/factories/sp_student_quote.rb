FactoryGirl.define do
  factory :sp_student_quote do
    sequence(:global_registry_id) {|n| (n * 5).to_s }
  end
end
