# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: awards
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  code        :string(255)
#  probability :float
#  count       :integer
#  game_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Award < ActiveRecord::Base
  include Redis::Objects
  extend FriendlyId
  friendly_id :code
  validates :code , :uniqueness => {:scope => :game_id } , :presence => true , :allow_blank => false
  validates :title , :presence => true , :allow_blank => false
  validates :probability , :presence => true , :allow_blank => false
  validates :count , :presence => true , :allow_blank => false

  belongs_to :game
  attr_accessible :code, :probability, :count , :game_id,:title
  counter :left_count , :key => '#{Rails.env}/bonus/#{code}'
  scope :not_over , where{ count > 0 }
  scope :over , where{ count <= 0 }
  after_save :update_left_count_in_redis!
  
  def update_left_count_in_redis!
    self.left_count.clear
    self.left_count.incr self.count
  end
  
  def update_left_count_into_db!
    self.count = self.left_count.value
    self.save if self.changed?
    self
  end
end
