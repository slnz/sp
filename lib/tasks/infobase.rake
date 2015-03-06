namespace :infobase do
  desc "Pull down all the staff from infobase and make sure they exist in SM"
  task pull: :environment do
    params = {'entity_type' => 'person',
              'filters[owned_by]' => 'us_infobase',
              'filters[is_staff]' => 'true',
              'page' => '1'}
    first_page = GlobalRegistry::Entity.get(params)
    process_page(first_page)
    2.upto(first_page['meta']['total_pages']) do |i|
      params['page'] = i
      process_page(GlobalRegistry::Entity.get(params))
    end
  end

end

def process_page(page)
  page['entities'].each do |e|
    person = e['person']
    puts person['id']
    notification = {
      'triggered_by' => 'us_infobase',
      'entity_type' => 'person',
      'id' => person['id']
    }
    Gr::Notification.perform_async(notification)
  end
end