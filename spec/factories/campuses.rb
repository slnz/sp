FactoryGirl.define do
  factory :campus, class: TargetArea do
    name 'String'
    city 'String'
    country 'String'
    region 'String'
    isSecure true
    type 'String'
  end
end
