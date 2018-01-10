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
gem 'bulk_insert'
gem 'carrierwave', '~> 1.0'

gem_group :development, :test do
  gem 'sdoc'
  gem 'highline'
  gem 'rails-erd'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'quiet_assets'
  gem 'awesome_print'
  gem 'byebug'
  gem 'faker'
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

after_bundle do
  remove_dir "test"
  remove_file "README.rdoc"
  remove_file ".gitignore"
  copy_file ".gitignore"
  copy_file ".dockerignore"
  copy_file "Dockerfile"
  copy_file "docker-compose.yml"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit by larvata template.' }
  run 'git flow init'

  generate 'devise:install'
  generate 'devise User'
  generate 'devise:views'
  generate 'simple_form:install --bootstrap'

  rails_command('db:create')
  rails_command('db:migrate')
end
