namespace :sys do
  desc "Reset all system data."
  task :reset => [
    "tmp:clear",
    "log:clear",
    "db:drop",
    "db:create",
    "db:migrate",
    "db:seed",
  ]
end
