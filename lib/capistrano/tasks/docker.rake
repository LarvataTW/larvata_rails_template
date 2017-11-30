namespace :docker do

  desc '建立程式的 docker image。'
  task :build do
    on roles(:app) do
      within release_path do
        execute :docker, "build --rm -t #{fetch(:application)} ."
      end
    end
  end

  desc '將程式透過 docker-compose 啟動。'
  task :compose do
    on roles(:app) do
      previous = capture("ls -t1 #{releases_path} | sed -n '2p'").to_s.strip
      within "#{releases_path}/#{previous}" do
        execute :'docker-compose', "down"
      end
      within release_path do
        execute :'docker-compose', "up -d"
      end
    end
  end

  desc '強制移除程式的 docker container。'
  task :kill do
    on roles(:app) do
      within release_path do
        execute :'docker-compose', "down; true"
        execute :'docker-compose', "rm -sf; true"
        execute :'docker', "stop #{fetch(:application)}; true"
        execute :'docker', "rm -f #{fetch(:application)}; true"
      end
    end
  end

  desc '檢視 docker 的 log。'
  task :logs do
    on roles(:app) do
      within release_path do
        execute :'docker-compose', "logs -f"
      end
    end
  end

  desc '進入程式的 docker container shell。'
  task :shell do
    roles(:app).each do | host |
      cmd = "ssh -t -p %s %s@%s /usr/bin/env docker exec -it %s sh" % [host.port, host.user, host.hostname, fetch(:application)]
      system cmd
    end
  end

end
