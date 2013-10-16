desc "update counter in redis to db"
namespace :counter_update do
  task :redis_to_db => :environment do
    Bonus.find_each do|bonus|
      bonus.count = bonus.left_count.value
      bonus.save if bonus.changed?
    end
  end
end