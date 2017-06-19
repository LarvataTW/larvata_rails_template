set :application, 'your_app_name'
set :keep_releases, 3
set :repo_url, 'git@bitbucket.org:larvata-tw/your_app_name.git'
set :deploy_to, '/www/your_app_name'
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

append :linked_files, 'docker.env'
append :linked_dirs, 'log', 'tmp', 'public/.well-known/acme-challenge', 'public/system', 'public/assets'

# Custom Variables
set :image_name, 'your_docker_image_name'
set :container_name, 'your_docker_container_name'
ask :server_is_mac, 'N'

task :set_docker_path do
  if fetch(:server_is_mac) == 'Y'
    set :docker, `which docker`.chomp
    set :docker_compose, `which docker-compose`.chomp
  else
    set :docker, 'docker'
    set :docker_compose, 'docker-compose'
  end
end

before :deploy, :set_docker_path

namespace :deploy do

  desc 'Running a docker containers for this project.'
  task :dockerize do
    on roles(:web) do
      previous = capture("ls -t1 #{releases_path} | sed -n '2p'").to_s.strip
      execute "cd #{release_path} && #{fetch(:docker)} build --rm -t #{fetch(:image_name)} ."
      execute "cd #{releases_path}/#{previous} && #{fetch(:docker_compose)} down"
      execute "cd #{release_path} && #{fetch(:docker_compose)} up -d"
      execute "cd #{shared_path} && chmod 777 log tmp"
    end
  end

  desc 'Kill the application docker container.'
  task :kill_docker do
    on roles(:web) do
      execute "#{fetch(:docker)} stop #{fetch(:container_name)}; docker rm -f #{fetch(:container_name)}"
    end
  end

  desc 'Precompile Assets'
  task :precompile do
    on roles(:web) do
      execute "#{fetch(:docker)} exec #{fetch(:container_name)} sh -c 'cd /home/app && RAILS_ENV=production bundle exec rake assets:precompile'"
    end
  end

  desc 'Migrate Database'
  task :migrate do
    on roles(:db) do
      execute "#{fetch(:docker)} exec #{fetch(:container_name)} sh -c 'cd /home/app && RAILS_ENV=production bundle exec rake db:migrate'"
    end
  end

  desc 'Init Database'
  task :init_db do
    on roles(:db) do
      set :mysql, `which mysql`.chomp
      ask :db_host, 'localhost'
      ask :db_name, 'test'
      ask :db_user, 'test'
      ask :db_password, 'test'
      ask :db_root_password, ''
      set :query,
        "CREATE DATABASE IF NOT EXISTS #{fetch(:db_name)} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; \
         CREATE USER '#{fetch(:db_user)}'@'%' IDENTIFIED BY '#{fetch(:db_password)}'; \
         GRANT ALL PRIVILEGES ON #{fetch(:db_name)}.* TO '#{fetch(:db_user)}'@'%'; \
         FLUSH PRIVILEGES;"
      execute "#{fetch(:mysql)} -v -u root -p#{fetch(:db_root_password)} -h #{fetch(:db_host)} -e \"#{fetch(:query)}\""
    end
  end

  desc 'Reset Database'
  task :reset_db do
    on roles(:db) do
      set :reset_cmd,
        "cd /home/app && \
         export RAILS_ENV=production; \
         export DISABLE_DATABASE_ENVIRONMENT_CHECK=1; \
         bundle exec rake db:drop && \
         bundle exec rake db:create && \
         bundle exec rake db:schema:load && \
         bundle exec rake db:seed"
      execute "#{fetch(:docker)} exec #{fetch(:container_name)} sh -c '#{fetch(:reset_cmd)}'"
    end
  end

  desc "Tail Rails Logs From Server"
  task :logs do
    on roles(:web) do
      execute "cd #{shared_path}/log && tail -f production.log"
    end
  end

  desc "Attach To Docker Container Bash Shell"
  task :shell do
    roles(:web).each do |host|
      cmd = "ssh -t -p %s %s@%s docker exec -it %s bash" % [host.port, host.user, host.hostname, fetch(:container_name)]
      system cmd
    end
  end

  desc "Attach To Rails Console In Docker Container"
  task :console do
    roles(:web).each do |host|
      cmd = "ssh -t -p %s %s@%s docker exec -it %s 'bash -c \"cd /home/app && bundle exec rails console production\"'" \
            % [host.port, host.user, host.hostname, fetch(:container_name)]
      system cmd
    end
  end

  desc 'Show deployed revision'
  task :revision do
    on roles(:web) do
      execute "cat #{current_path}/REVISION"
    end
  end

  after 'deploy:published', 'deploy:dockerize'
  after 'deploy:dockerize', 'deploy:precompile'
  after 'deploy:precompile', 'deploy:migrate'

end
