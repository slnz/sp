FactoryGirl.define do
  factory :sp_project do
    sequence(:name) {|n| "Project1#{n}" }
    description 'String'
    year { SpApplication.year }
    display_location 'String'
    start_date '06/10/2014 12:00:00'
    end_date '06/12/2014 12:00:00'
    student_cost 1
    max_accepted_men 10
    max_accepted_women 10
    show_on_website true
    project_contact_name 'String'
    city 'String'
    country 'String'
    primary_partner 'String'
    secondary_partner 'String'
    report_stats_to 'String'
    partner_region_only false
    apply_by_date '05/10/2012 12:00:00'
  end
end
