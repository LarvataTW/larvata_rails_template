require "capistrano/setup"
require "capistrano/deploy"
require "hipchat/capistrano"

# Hipchat hook
set :hipchat_token, ""
set :hipchat_room_name, ""
set :hipchat_announce, true

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
