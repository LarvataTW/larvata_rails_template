def source_paths
      Array(super)
        [File.expand_path(File.dirname(__FILE__))]
end



remove_file "Gemfile"
run "touch Gemfile"
#be sure to add source at the top of the file
add_source 'https://rubygems.org'
gem 'rails', '4.2.1'
gem 'uglifier'
gem 'jquery-rails'
gem 'turbolinks'
gem 'devise'
gem 'cancancan'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'compass'
gem 'simple_form'
gem 'Kaminari'
gem 'sdoc', group: :doc
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

run "bundle"

generate 'devise:install'
generate 'devise User'
generate 'devise:views'

rake 'db:migrate'
git :init
git add: '.'
