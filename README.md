# Rails Template

## 使用說明

建議複製本專案的 railsrc 到 ~/.railsrc，
並且修改其中的 template 路徑以符合實際的本機路徑。

```
rails new \
  --database mysql \
  --skip-spring \
  --skip-test-unit \
  --skip-turbolinks \
  --template=/your/path/to/larvata-rails-template/template.rb
  YOUR_RAILS_APP_NAME
```

## 參考資料

* http://guides.rubyonrails.org/rails_application_templates.html
* http://railsapps.github.io/rails-application-templates.html
* https://www.sitepoint.com/rails-application-templates-real-world/
* http://brewhouse.io/2016/02/01/introducing-brewhouse-rails-template.html
* https://github.com/RailsApps/rails_apps_composer
* https://github.com/lewagon/rails-templates
* https://github.com/mattbrictson/rails-template
* https://github.com/thoughtbot/suspenders
* https://www.justinweiss.com/articles/fast-consistent-setup-for-your-ruby-and-rails-projects/

# Rails Dockerize

## References

* https://github.com/phusion/passenger-docker
* https://docs.docker.com/engine/examples/
* https://docs.docker.com/compose/rails/
* https://semaphoreci.com/community/tutorials/dockerizing-a-ruby-on-rails-application
