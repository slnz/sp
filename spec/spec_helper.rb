# require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  #require 'webmock/rspec'

  require 'simplecov'
  require 'webmock/rspec'
  SimpleCov.start 'rails' do
    add_filter "vendor"
  end

  require 'sidekiq/testing'
  Sidekiq::Testing.fake!

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.render_views

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
    config.infer_spec_type_from_file_location!
    #config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
    #config.include Devise::TestHelpers, :type => :controller
    config.include FactoryGirl::Syntax::Methods

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      #DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
      @geocode_body = %|
{
   "results" : [
      {
         "address_components" : [
            {
               "long_name" : "String",
               "short_name" : "String",
               "types" : [ "neighborhood", "political" ]
            },
            {
               "long_name" : "Cork",
               "short_name" : "Cork",
               "types" : [ "administrative_area_level_2", "political" ]
            },
            {
               "long_name" : "Cork",
               "short_name" : "Cork",
               "types" : [ "administrative_area_level_1", "political" ]
            },
            {
               "long_name" : "Ireland",
               "short_name" : "IE",
               "types" : [ "country", "political" ]
            }
         ],
         "formatted_address" : "String, Co. Cork, Ireland",
         "geometry" : {
            "bounds" : {
               "northeast" : {
                  "lat" : 52.2006701,
                  "lng" : -8.3786194
               },
               "southwest" : {
                  "lat" : 52.1887815,
                  "lng" : -8.4010359
               }
            },
            "location" : {
               "lat" : 52.19418289999999,
               "lng" : -8.386761099999999
            },
            "location_type" : "APPROXIMATE",
            "viewport" : {
               "northeast" : {
                  "lat" : 52.2006701,
                  "lng" : -8.3786194
               },
               "southwest" : {
                  "lat" : 52.1887815,
                  "lng" : -8.4010359
               }
            }
         },
         "partial_match" : true,
         "types" : [ "neighborhood", "political" ]
      }
   ],
   "status" : "OK"
}
|
      stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=String,String&language=en&sensor=false").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => @geocode_body, :headers => {})
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

  end
#
# end
#
# Spork.each_run do
#   # This code will be run each time you run your specs.
#   FactoryGirl.reload
#
# end

