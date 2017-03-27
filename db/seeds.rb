# 依照檔名依序引入並執行其他 seed 腳本
Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed }
