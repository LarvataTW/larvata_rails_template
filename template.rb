# Add the current directory to the path Thor uses to look up files
def source_paths
  Array(super) +
    [File.expand_path(File.dirname(__FILE__))]
end

remove_file "Gemfile"
run "touch Gemfile"
add_source 'https://rubygems.org'

gem 'rails', '~> 5.2.0'
gem 'rails-i18n'
gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'compass-rails'
gem 'nprogress-rails', '~> 0.2.0.2'
gem "jquery-fileupload-rails"
gem 'puma'
gem 'mysql2'
gem 'uglifier'
gem 'devise'
gem 'devise-i18n'
gem 'devise_token_auth'
gem 'jsonapi-resources'
gem 'swagger_ui_engine'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'thor'
gem 'grape'
gem 'grape-swagger'
gem 'enum_help'
gem 'cocoon'
gem 'aasm'
gem 'font-awesome-rails'
gem 'pundit'
gem 'i18n-js'
gem 'rolify'
gem 'ransack'
gem 'seed_dump'
gem 'photoswipe-rails'
gem 'paper_trail'
gem 'simple_form'
gem 'bulk_insert'
gem 'carrierwave', '~> 1.0'
gem 'wysiwyg-rails'
gem 'hashie'
gem 'every8d'
gem 'paperclip'
gem 'paranoia'
gem 'thredded'
gem 'rack-cors', require: 'rack/cors'

gem_group :development, :test do
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'sdoc'
  gem 'highline'
  gem 'rails-erd'
  gem 'xray-rails'
  gem 'dotenv-rails'
  gem 'awesome_print'
  gem 'byebug'
  gem 'faker'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-byebug'
  gem 'pry-remote'
  gem 'pry-stack_explorer'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'sshkit-sudo'
  gem 'capistrano'
  gem 'capistrano-wal-e'
  gem 'capistrano-ssh-doctor'
  gem 'capistrano-safe-deploy-to'
  gem 'capistrano-deploy_hooks'
  gem 'larvata_scaffold', git: 'https://github.com/LarvataTW/larvata_scaffold.git'
  gem 'rspec-rails'
  gem 'fabrication'
  gem 'database_cleaner'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rspec', require: false
  gem 'fuubar'
  gem 'shoulda'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  end

gem_group :production do
  gem 'httparty'
  gem 'aws-sdk-s3'
  gem 'rails_12factor'
  gem 'exception_notification'
end

inside 'config' do

  remove_file 'boot.rb'
  create_file 'boot.rb' do <<-EOF
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'
EOF
  end

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
  insert_into_file 'config/application.rb', after: "config.load_defaults 5.2\n" do <<~CONF
    config.time_zone = 'Asia/Taipei'
    config.i18n.default_locale = "zh-TW"
    config.generators do |g|
      g.test_framework :rspec, fixture_replacement: :fabrication
      g.fixture_replacement :fabrication, dir: "spec/fabricators"
    end
  CONF
  end

  insert_into_file 'app/controllers/application_controller.rb', after:"class ApplicationController < ActionController::Base\n" do <<~CONF
    include Pundit
    protect_from_forgery
  CONF
  end


  remove_dir "test"
  remove_file "README.rdoc"

  remove_file ".gitignore"
  copy_file ".gitignore"
  copy_file "admin.css.scss", "app/assets/stylesheets/admin.css.scss"
  copy_file "admin.js", "app/assets/javascripts/admin.js"
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
  rails_command('db:create')
  generate 'larvata_scaffold:install'
  rails_command('db:migrate')
  generate 'larvata_scaffold:controller user --admin'
  rails_command('db:migrate')
  generate 'rolify admin User'
  rails_command('db:migrate')
  remove_file "db/seeds.rb"
  copy_file "db/seeds.rb"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit by larvata template.' }
  run 'git flow init'
end
