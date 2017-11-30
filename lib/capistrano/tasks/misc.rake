namespace :misc do

  desc '列出 Server 端的環境變數。'
  task :server_env do
    on roles(:all) do
      puts capture(:env)
    end
  end

  desc '列出本地端的環境變數。'
  task :local_env do
    on(:local) do
      puts capture(:env)
    end
  end

  desc "重設釋出目錄為部署帳號擁有，以供 Capistrano 進行清理。"
  task :reset_permission do
    on roles(:all) do
      sudo :chown, "-R `whoami` #{releases_path}/"
    end
  end

end
