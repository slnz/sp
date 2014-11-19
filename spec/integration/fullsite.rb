gem 'pry'
gem 'pry-remote'
gem 'pry-stack_explorer'
gem 'pry-byebug'
gem 'rspec'
gem 'rspec-expectations'

require "watir-webdriver"
require "pry"
require "rspec"
require "rspec/expectations"

include RSpec::Matchers

def test_site
  puts
  puts "NOTE - Expecting a test db with app structure.  If needed, rebuild it with 'RAILS_ENV=test bundle exec rake db:schema:load'."
  puts "NOTE - Expecting a test server running on localhost:3000.  If needed, run 'RAILS_ENV=test bundle exec rails server' to start it."
  puts

  #WebMock.allow_net_connect!

  #byebug

  # remember browser so we can use irb without having it open a new browser each time
  #begin
    puts "Loading browser..."
    $b ||= Watir::Browser.new
    b = $b
    b.goto 'http://localhost:3000/watir/prepare'
  #rescue
  #  $b = Watir::Browser.new
  #  retry
  #end

  puts "Loading http://localhost:3000"
  b.goto 'http://localhost:3000/'

  # log out if possible
  #puts "Sleeping before logout check"
  if $b.div(class: 'logout').present?
    $b.div(class: 'logout').a.click
    $bb.goto 'http://localhost:3000/'
  end

  # log in
  puts "Test staff (Coordinator) login"
  Watir::Wait.until { b.div(id: 'signinwith').present? }
  b.div(id: 'signinwith').elements(:css => 'a').first.click # relay
  if b.text_field(:id => 'username').present?
    b.text_field(:id => 'username').set 'tester@mailinator.com'
    b.text_field(:id => 'password').set 'tester123'
    b.input(:id => 'btn_signin').click
  end
  b.goto 'http://localhost:3000/watir/give_staff_access'
  halt_if_error

  # new project
  b.goto 'http://localhost:3000/admin'
  expect($b.text).to match(/Projects/)
  #expect($b.a(class: 'add withicon', href: '/admin/projects/new').present?).to be true
  $b.a(class: 'add withicon', href: '/admin/projects/new').click
  $b.text_field(id: "sp_project_name").set "US Project"
  $b.text_field(id: "sp_project_display_location").set "Florida"
  $b.text_field(id: "sp_project_city").set "Lake Hart"
  $b.select_list(id: "sp_project_state").select "Florida"
  $b.select_list(id: "sp_project_country").select "United States"
  $b.select_list(id: "sp_project_world_region").select "USA/Canada"

=begin
  # log back in
  puts "Log back in"
  Watir::Wait.until { b.input(:id => 'social-username').present? }
  b.text_field(:id => 'social-username').set 'andrewroth'
  b.text_field(:id => 'social-password').set File.read("test/integration/password.txt").chomp
  b.input(:value => 'Login').click

  # go to profile
  puts "Go to profile"
  Watir::Wait.until { b.a(:class => 'logout').present? }
  b.element(:css => '#loggedin a').click

  # go to portfolio
  puts "Go to portfolio"
  Watir::Wait.until { b.a(:class => 'logout').present? }
  $b.div(:id => 'my_stuff').as.find{ |el| el.text =~ /Portfolio/ }.click
=end
end

def run
  load "spec/integration/fullsite.rb"
  #t = TestSite.new("test_site")
  #t.test_site
  test_site
end

def reset
  $b = nil
  load "spec/integration/fullsite.rb"
end

def halt_if_error
  if $b.text.include?("============")
    throw "ERROR DETECTED"
  end
end
#test_site
