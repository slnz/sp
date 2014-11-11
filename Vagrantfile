# Commands required to setup working docker environment, link
# containers etc.
$setup = <<SCRIPT
# Stop and remove any existing containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Build containers from Dockerfiles
docker build -t postgres /app/docker/postgres
docker build -t rails /app

# Run and link the containers
docker run -d -v /var/lib/postgresql --name dbdata postgres:latest echo Data-only container for postgres
docker run -d -p 5432:5432 --volumes-from dbdata --name postgres -e POSTGRESQL_USER=docker -e POSTGRESQL_PASS=docker postgres
docker run --name redis -d redis redis-server --appendonly yes
docker run -d -p 3000:3000 -v /app:/app --link redis:redis --link postgres:db --name rails rails
cp -n /app/config/database.example.yml /app/config/database.yml
cp -n /app/config/redis.example.yml /app/config/redis.yml
docker run -i -t -v /app:/app --link redis:redis --link postgres:db  --rm rails bash -c "bundle exec rake db:create"
docker run -i -t -v /app:/app --link redis:redis --link postgres:db  --rm rails bash -c "pg_restore -h $DB_PORT_5432_TCP_ADDR -d summer_missions -U docker -W db/summer_missions.dmp "
SCRIPT

# Commands required to ensure correct docker containers
# are started when the vm is rebooted.
$start = <<SCRIPT
docker start postgres
docker start redis
docker start rails
SCRIPT

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Setup resource requirements
  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # need a private network for NFS shares to work
  config.vm.network 'private_network', ip: '192.168.50.5'

  # Rails Server Port Forwarding
  config.vm.network 'forwarded_port', guest: 3000, host: 3001

  # Ubuntu
  config.vm.box = 'ubuntu/trusty64'

  # Install latest docker
  config.vm.provision 'docker'

  # Must use NFS for this otherwise rails
  # performance will be awful
  config.vm.synced_folder '.', '/app', type: 'nfs'

  # Setup the containers when the VM is first
  # created
  config.vm.provision 'shell', inline: $setup

  # Make sure the correct containers are running
  # every time we start the VM.
  config.vm.provision 'shell', run: 'always', inline: $start
end
