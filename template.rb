# Add the current directory to the path Thor uses to look up files
def source_paths
  Array(super) +
    [File.expand_path(File.dirname(__FILE__))]
end

remove_file "Gemfile"
run "touch Gemfile"
add_source 'https://rubygems.org'

gem 'rails', '~> 5.1.4'
gem 'rails-i18n'

gem 'jquery-rails'
gem 'sass-rails'
gem 'compass-rails'

gem 'mysql2'
gem 'uglifier' # Ruby wrapper for UglifyJS JavaScript compressor.

gem 'devise'
gem 'devise-i18n'

gem 'kaminari'
gem 'kaminari-i18n'

gem 'grape'
gem 'grape-swagger'

gem 'aasm'
gem 'pundit'
gem 'ransack'
gem 'paper_trail'
gem 'simple_form'
gem 'bulk_insert' # Efficient bulk inserts with ActiveRecord.
gem 'carrierwave', '~> 1.0'

gem_group :development, :test do
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'sdoc'
  gem 'highline'
  gem 'rails-erd'
  gem 'xray-rails'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'awesome_print'
  gem 'byebug'
  gem 'faker'
  gem 'fabrication'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-livereload'
  gem 'bullet' # help to kill N+1 queries and unused eager loading.
  gem 'sshkit-sudo'
  gem 'capistrano'
  gem 'capistrano-wal-e'
  gem 'capistrano-ssh-doctor'
  gem 'capistrano-safe-deploy-to'
  gem 'capistrano-deploy_hooks'
  gem 'larvata_scaffold', git: "https://github.com/LarvataTW/larvata_scaffold.git"
end

gem_group :production do
  gem 'httparty'
  gem 'exception_notification'
end

inside 'config' do
  remove_file 'database.yml'
  create_file 'database.yml' do <<-EOF
default: &default
  adapter: mysql2
  encoding: utf8mb4
  collation: utf8mb4_unicode_ci
  host: <%= ENV['DB_HOST'] %>
  database: <%= ENV['DB_NAME'] %>
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

test:
  <<: *default
  database: #{app_name}_test

development:
  <<: *default
  database: #{app_name}_development

production:
  <<: *default
EOF
  end
end

def production_config
  <<~HEREDOC
  config.action_mailer.default_url_options = { host: "http://\#{ENV['MAIL_DOMAIN']}" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :authentication => :plain,
    :address => ENV["MAIL_SERVER"],
    :port => ENV["MAIL_PORT"],
    :domain => ENV["MAIL_DOMAIN"],
    :user_name => ENV["MAIL_USER"],
    :password => ENV["MAIL_PASSWORD"],
  }

  config.generators do |g|
    g.test_framework :rspec, fixture_replacement: :fabrication
    g.fixture_replacement :fabrication, dir: "spec/fabricators"
  end

  Rails.application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[\#{Rails.application.class.parent}] ",
      :sender_address => %{"\#{Rails.application.class.parent}" <no-reply@\#{ENV["MAIL_DOMAIN"]}>},
      :exception_recipients => ENV["MAIL_RECEIVER"],
    },
    :mattermost => {
      :webhook_url => ENV["MATTERMOST_WEBHOOK_URL"],
      :channel => ENV["MATTERMOST_CHANNEL"],
      :username => ENV["MATTERMOST_USERNAME"],
      :avatar => ENV["MATTERMOST_ICON"],
    }
  HEREDOC
end
environment production_config, env: 'production'

after_bundle do
  remove_dir "test"
  remove_file "README.rdoc"

  remove_file "db/seeds.rb"
  copy_file "db/seeds.rb"

  remove_file ".gitignore"
  copy_file ".gitignore"

  copy_file "config/nginx.conf"
  copy_file "config/nginx.env.conf"
  copy_file "config/my.cnf"
  copy_file ".env"
  copy_file ".dockerignore"
  copy_file "Dockerfile"
  copy_file "docker-compose.yml"

  generate 'rspec:install'
  generate 'devise:install'
  generate 'devise User'
  generate 'devise:views'
  generate 'simple_form:install --bootstrap'

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit by larvata template.' }
  run 'git flow init'

  # rails_command('db:create')
  # rails_command('db:migrate')
end
