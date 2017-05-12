server 'your.server', user: 'rails', roles: %w{app db web}, port: 22

# 可以在各別環境覆寫 deploy.rb 的設定

# set :deploy_to, '/path/to/somewhere/new'
# append :linked_files, '/path/to/some/new/file'
# namespace :deploy do
#   Rake::Task["my_task"].clear_actions
#   desc 'overriding my_task in deploy.rb'
#   task :my_task do
#     on roles(:web) do
#       previous = capture("ls -Ct #{releases_path} | awk '{print $2}'").to_s.strip
#       execute "cd #{releases_path}/#{previous} && do something in previous release directory"
#       execute "cd #{release_path} && do something in current release directory"
#     end
#   end
#   after 'deploy:published', 'deploy:my_task'
# end
