gem 'rails', '5.1'
gem 'rails-i18n'

gem 'jquery-rails'
gem 'sass-rails'
gem 'compass-rails'

gem 'mysql2'
gem 'uglifier'
# gem 'jbuilder'
# gem 'turbolinks'

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

gem_group :test do
  gem 'sqlite3'
  gem 'rspec'
end

gem_group :development, :test do
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
  gem 'rspec'
  gem 'highline'
  gem 'sshkit-sudo'
  gem 'capistrano'
  gem 'capistrano-wal-e'
  gem 'capistrano-ssh-doctor'
  gem 'capistrano-safe-deploy-to'
  gem 'capistrano-deploy_hooks'
end

gem_group :production do
  gem 'httparty'
  gem 'exception_notification'
end

group :darwin do
  gem 'rb-fsevent'
end

group :linux do
  gem 'rb-inotify'
end

run "rm README.rdoc"
run "echo '# #{@app_name.titleize}' >> README.md"
run "bundle"

generate 'devise:install'
generate 'devise User'
generate 'devise:views'
generate 'simple_form:install --bootstrap'

rake 'db:migrate'

git :init
git add: '.'
git commit: "-a -m 'Initial commit by Rails bootstrap script.'"

run 'git flow init'