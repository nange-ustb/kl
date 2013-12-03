# -*- encoding : utf-8 -*-
class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts 'Doing hard work'
  end
end
