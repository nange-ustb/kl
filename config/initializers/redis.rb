# -*- encoding : utf-8 -*-
require 'redis'
require 'redis/objects'
Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379 , :db => "lottrygame_v2_#{Rails.env}" )
Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379 , :db => "lottrygame_v2_#{Rails.env}") if Rails.env.development? or Rails.env.test?
