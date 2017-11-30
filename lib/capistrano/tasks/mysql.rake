namespace :mysql do

  desc '建立 MySQL 資料庫。'
  task :create do
    on roles(:db) do
      ask :mysql, 'mysql'
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

  desc '匯出 MySQL 資料庫。'
  task :dump do
    on roles(:db) do
      ask :mysqldump, 'mysqldump'
      ask :db_host, 'localhost'
      ask :db_name, 'test'
      ask :db_user, 'test'
      ask :db_password, 'test'
      execute "#{fetch(:mysqldump)} -u #{fetch(:db_user)} -p#{fetch(:db_password)} -h #{fetch(:db_host)} #{fetch(:db_name)} | gzip > /tmp/#{fetch(:db_name)}.sql.gz"
      cmd = "scp -P %s %s@%s:/tmp/%s.sql.gz ./" % [host.port, host.user, host.hostname, fetch(:db_name)]
      if ENV['BASTION']
        cmd = "scp -o 'ProxyCommand ssh -p %s %s@%s nc %s %s' %s@%s:/tmp/%s.sql.gz ./" % \
          [ENV['BASTION_PORT'], ENV['BASTION_USER'], ENV['BASTION_HOST'], host.hostname, host.port, host.user, host.hostname,fetch(:db_name)]
      end
      system cmd
    end
  end

end
