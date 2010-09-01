#require 'dragonfly'
#
#app = Dragonfly[:images]
#app.configure_with(:rmagick)
#app.configure_with(:rails)
#
#app.define_macro(ActiveRecord::Base, :image_accessor)
#
#
#app.datastore = Dragonfly::DataStorage::S3DataStore.new
#
#app.url_path_prefix = '/media'
#
#app.datastore.configure do |c |
#  c.bucket_name = 'vacumi_dev'
#  c.access_key_id = '067B7PVTRAQ34ZTC4MG2'
#  c.secret_access_key = 'bNO9xZIx+e55fnQ4z7G3nM+1TaaBGVQ3aq8U9pW8'
#end