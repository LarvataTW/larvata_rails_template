require 'dotenv/load'

# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

SSHKit::Backend::Netssh.configure do |ssh|
  ssh.connection_timeout = 30
  ssh.ssh_options = {
    forward_agent: true,
    auth_methods: %w(publickey password)
  }
end

if ENV['MATTERMOST_URI']
  require 'net/http'
  require 'net/https'
  require 'capistrano/deploy_hooks'
  require 'capistrano/deploy_hooks/messengers/mattermost'
  set :deploy_hooks, {
    messenger: Capistrano::DeployHooks::Messengers::Mattermost,
    webhook_uri: ENV['MATTERMOST_URI'],
    channels: ENV['MATTERMOST_CHANNEL'],
    icon_url: ENV['MATTERMOST_ICON'],
  }
end

if ENV['BASTION']
  require 'net/ssh/proxy/command'
  bastion_host = ENV['BASTION_HOST']
  bastion_user = ENV['BASTION_USER']
  bastion_port = ENV['BASTION_PORT']
  ssh_command = "ssh -p #{bastion_port} #{bastion_user}@#{bastion_host} -W %h:%p"
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
end

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
