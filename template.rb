def source_paths
      Array(super)
        [File.expand_path(File.dirname(__FILE__))]
end



remove_file "Gemfile"
run "touch Gemfile"
#be sure to add source at the top of the file
add_source 'https://rubygems.org'
gem 'rails', '4.2.4'
gem 'rails-i18n', '~> 4.0.0'
gem 'uglifier'
gem 'jquery-rails'
gem 'turbolinks'
gem 'devise'
gem 'devise-i18n'
gem 'cancancan'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'compass-rails'
gem 'simple_form'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'sdoc', group: :doc
gem 'bulk_insert'  # 大量匯入用

#搜尋
gem 'ransack'

#gem and gem_group will work from Rails Template API
gem_group :development, :test do
    gem 'sqlite3'
    gem 'spring'
    gem 'quiet_assets'
    gem 'pry-rails'
    gem 'byebug'
    gem 'awesome_print'
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'faker'
end

gem_group  :production do
    gem 'exception_notification'
end

run "bundle"

generate 'devise:install'
generate 'devise User'
generate 'devise:views'
generate 'simple_form:install --bootstrap'

rake 'db:migrate'
git :init
git add: '.'
git flow init
