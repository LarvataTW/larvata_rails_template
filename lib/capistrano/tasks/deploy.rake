namespace :deploy do

  desc '顯示目前部署的版本。'
  task :revision do
    on roles(:app) do
      execute "cat #{current_path}/REVISION"
    end
  end

  desc '確認本機端程式版本與遠端一致。'
  task :revision_checker do
    unless `git rev-parse develop` == `git rev-parse origin/develop` && `git rev-parse master` == `git rev-parse origin/master`
      puts "警告：本地端的 develop 與 master branch 跟遠端 origin 不同步！"
      puts "不跟你好了啦 (╬￣皿￣)=○"
      exit
    end
  end

  before :deploy, "deploy:revision_checker"

end
