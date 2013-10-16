# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Game < ActiveRecord::Base
  include Redis::Objects
  extend FriendlyId
  friendly_id :code

  attr_accessible :code,:title,:awards_attributes
  validates :code , :uniqueness => true , :presence => true , :allow_blank => false
  validates :title , :presence => true , :allow_blank => false
  has_many :awards , :dependent => :destroy
  accepts_nested_attributes_for  :awards, :allow_destroy => true
  list :award_pool
  after_save :update_digit_pool!

  def play!
    bonus_code = self.award_pool.to_a.sample(1)
    if bonus_code and award = awards.where(:code=>bonus_code).first
      if award.left_count > 0
        award.left_count.decr
        award.update_left_count_into_db!
        return bonus_code
      end
    end
    nil
  end

  def update_digit_pool!
    award_pool.clear
    award_probabilities_and_codes = self.awards.not_over.collect{|bns| {:probability => bns.probability , :code => bns.code } }
    
    pool_size_limit = 10000
    pool_size = pool_size_limit * award_probabilities_and_codes.sum{|_| _[:probability]}
    pool_size = pool_size_limit if pool_size < pool_size_limit
    
    pool = Array.new(pool_size){nil}
    award_probabilities_and_codes.each do|probability_and_code|
      probability_and_code[:count] = ( pool_size * probability_and_code[:probability] ).to_i
    end
    start_index = 0
    puts award_probabilities_and_codes.inspect
    puts pool[0,900].inspect
    award_probabilities_and_codes.each do| probability_and_code_and_count |
      pool[ start_index , probability_and_code_and_count[:count] ] = 
        [probability_and_code_and_count[:code]] * probability_and_code_and_count[:count].to_i
      start_index += probability_and_code_and_count[:count]
    end
    pool.sort_by{|_|rand}.each do |award|
      award_pool << award
    end
  end
end
