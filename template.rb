gem 'rails', '~> 5.1.4'
gem 'rails-i18n'

gem 'jquery-rails'
gem 'sass-rails'
gem 'compass-rails'

gem 'mysql2'
gem 'uglifier'

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
gem 'bulk_insert'
gem 'carrierwave', '~> 1.0'

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'web-console'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'awesome_print'
  gem 'byebug'
  gem 'faker'
  gem 'sdoc'
  gem 'pry'
  gem 'pry-rails'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-livereload'
  gem 'rails-erd'
  gem 'bullet'
  gem 'highline'
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

after_bundle do
  run "rm README.rdoc"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }

  run 'git flow init'

  generate 'devise:install'
  generate 'devise User'
  generate 'devise:views'
  generate 'simple_form:install --bootstrap'

  rails_command('db:migrate')
end
