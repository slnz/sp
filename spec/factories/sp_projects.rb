FactoryGirl.define do
  factory :sp_project do
    name 'Project1'
    description 'String'
    year '2012'
    display_location 'String'
    start_date '05/10/2012 12:00:00'
    end_date '05/10/2012 12:00:00'
    student_cost 1
    max_accepted_men 1
    max_accepted_women 1
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