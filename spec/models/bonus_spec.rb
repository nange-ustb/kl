# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: bonus
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  code          :string(255)
#  probability   :float
#  count         :integer
#  bonus_pool_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Bonus do
  before{ @bonus = FactoryGirl.create( :bonus ) }
  after{ @bonus.left_count.clear }

  describe Bonus , "Bonus#left_count" do
    context "when initialize" do
      subject{@bonus.left_count}
      its(:class){ should == Redis::Counter }
    end
  end

  describe Bonus , "Bonus#update_left_count_in_redis" do
    context "when update left_count in redis" do
      subject{ @bonus.update_left_count_in_redis! }
      its("left_count.value"){ should == @bonus.count }
    end
  end

  describe Bonus , "Bonus#update_left_count_into_db" do
    context "when update left_count into db" do
      subject{ @bonus.update_left_count_into_db! }
      its("count"){ should == 0 }
    end
  end

end
