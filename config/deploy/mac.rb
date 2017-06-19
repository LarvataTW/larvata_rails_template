set :docker, '/usr/local/bin/docker'
set :docker_compose, '/usr/local/bin/docker-compose'
server 'your.mac.server', user: 'rails', roles: %w{app db web}, port: 22
