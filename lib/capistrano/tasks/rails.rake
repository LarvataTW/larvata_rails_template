namespace :rails do

  desc '上傳 Rails 設定檔。'
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc '編譯 Rails 的靜態資源。'
  task :precompile do
    on roles(:app) do
      execute "cd #{shared_path} && chmod 777 log tmp"
      execute :docker, "exec #{fetch(:application)} sh -c 'cd /home/app && export RAILS_ENV=production; bundle exec rake assets:precompile'"
    end
  end

  desc '進入在 Docker container 內的 Rails console。'
  task :console do
    roles(:app).each do |host|
      docker_cmd = "export PATH=/usr/local/bin/:$PATH; /usr/bin/env docker exec -it #{fetch(:application)} bash -c \"cd /home/app; bundle exec rails console production\""
      cmd = "ssh -t -p %s %s@%s '%s'" % [host.port, host.user, host.hostname, docker_cmd]
      if ENV['BASTION']
        cmd = "ssh -t -o ProxyCommand='ssh -t -p %s %s@%s nc %s %s' %s@%s '%s'" % \
          [ENV['BASTION_PORT'], ENV['BASTION_USER'], ENV['BASTION_HOST'], host.hostname, host.port, host.user, host.hostname, docker_cmd]
      end
      system cmd
    end
  end

  desc '查看 Rails 的 log。'
  task :logs do
    on roles(:app) do
      execute "cd #{shared_path}/log && tail -f *.log"
    end
  end

  namespace :db do

    %w[create migrate seed].each do |command|
      desc "執行 rake db:#{command}。"
      task command do
        on roles(:app) do
          execute :docker, "exec #{fetch(:application)} sh -c 'cd /home/app && export RAILS_ENV=production; bundle exec rake db:#{command}'"
        end
      end
    end

    desc '重置 Rails 資料庫。'
    task :reset do
      on roles(:app) do
        set :reset_cmd,
          "cd /home/app && \
           export RAILS_ENV=production; \
           export DISABLE_DATABASE_ENVIRONMENT_CHECK=1; \
           bundle exec rake db:drop && \
           bundle exec rake db:create && \
           bundle exec rake db:schema:load && \
           bundle exec rake db:seed"
        execute :docker, "exec #{fetch(:application)} sh -c '#{fetch(:reset_cmd)}'"
      end
    end

  end

end
