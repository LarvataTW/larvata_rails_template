set :application, 'your_app_name'
set :image_name, 'your_docker_image_name'
set :container_name, 'your_docker_container_name'

set :keep_releases, 3
set :repo_url, 'git@bitbucket.org:larvata-tw/your_app_name.git'
set :deploy_to, '/www/your_app_name'

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

append :linked_files, 'docker.env'
append :linked_dirs, 'log', 'tmp', 'public/.well-known/acme-challenge', 'public/system', 'public/assets', 'certs'

namespace :deploy do

  desc 'Running a docker containers for this project.'
  task :dockerize do
    on roles(:web) do
      previous = capture("ls -t1 #{releases_path} | sed -n '2p'").to_s.strip
      execute "cd #{release_path} && docker build --rm -t #{fetch(:image_name)} ."
      execute "cd #{releases_path}/#{previous} && docker-compose down"
      execute "cd #{release_path} && docker-compose up -d"
      execute "cd #{shared_path} && chmod 777 log tmp"
    end
  end

  desc 'Kill the application docker container.'
  task :kill_docker do
    on roles(:web) do
      execute "docker stop #{fetch(:container_name)}; docker rm -f #{fetch(:container_name)}"
    end
  end

  desc 'Precompile Assets'
  task :precompile do
    on roles(:web) do
      execute "docker exec #{fetch(:container_name)} /bin/bash -c 'cd /home/app && RAILS_ENV=production bundle exec rake assets:precompile'"
    end
  end

  desc 'Migrate Database'
  task :migrate do
    on roles(:db) do
      execute "docker exec #{fetch(:container_name)} /bin/bash -c 'cd /home/app && RAILS_ENV=production bundle exec rake db:migrate'"
    end
  end

  desc 'Reset Database'
  task :reset_db do
    on roles(:db) do
      execute "docker exec #{fetch(:container_name)} bash -c 'cd /home/app && RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop'"
      execute "docker exec #{fetch(:container_name)} bash -c 'cd /home/app && RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:create'"
      execute "docker exec #{fetch(:container_name)} bash -c 'cd /home/app && RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:schema:load'"
      execute "docker exec #{fetch(:container_name)} bash -c 'cd /home/app && RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:seed'"
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

  after 'deploy:published', 'deploy:dockerize'
  after 'deploy:dockerize', 'deploy:precompile'
  after 'deploy:precompile', 'deploy:migrate'

end
