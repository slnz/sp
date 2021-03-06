redis_config = YAML.load(ERB.new(File.read(Rails.root.join('config', 'redis.yml').to_s)).result)
rails_env = ENV['RAILS_ENV'] || 'development'
host, port = redis_config[rails_env].split(':')

$redis = Redis.new(host: host, port: port)
