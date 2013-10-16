# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: bonus_pools
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe BonusPool do
  describe BonusPool , "#digit_pool" do
    context "when initialize a BonusPool" do
      subject{ FactoryGirl.create( :bonus_pool ) }
      its(:digit_pool){should be_is_a Redis::List}
    end
  end

  describe BonusPool , "#to_full_params" do
    before do
      @bonus_pool = FactoryGirl.create( :bonus_pool )
      @bonus_pool.update_digit_pool!
      @bonuses = 5.times.map do
        bonus = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool )
        bonus.update_left_count_in_redis!
      end
      @expecting_params =
        { @bonus_pool.code =>
          @bonuses.map do|bonus|
              {
                :code => bonus.code ,
                :count => bonus.count ,
                :probability => bonus.probability
              }
          end
        }
    end
    context "when read to_full_params" do
      subject{ @bonus_pool.to_full_params }
      it{ should == @expecting_params }
    end
  end

  describe BonusPool , "#update_digit_pool!" do

    describe "when total probability less than 1" do
      before do
        @bonus_pool = FactoryGirl.create( :bonus_pool )
        @bonus1 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.1 )
        @bonus2 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.2 )
        @bonus_pool.digit_pool.clear
        @bonus1.left_count.clear
        @bonus2.left_count.clear
        @bonus1.update_left_count_in_redis!
        @bonus2.update_left_count_in_redis!
      end
      context "when count total size of digit_pool" do
        subject{ @bonus_pool.update_digit_pool! }
        its( "digit_pool.length" ){should == 10000}
      end
      context "when count specified size of each bonus1" do
        subject do
            @bonus_pool.update_digit_pool!
            @bonus_pool.digit_pool.values.select{|at| at == @bonus1.code} 
        end
        its(:size){should == 1000 }
      end
      context "when count specified size of each bonus2" do
        subject do
          @bonus_pool.update_digit_pool!
          @bonus_pool.digit_pool.values.select{|at| at == @bonus2.code}
        end
        its(:size){should == 2000 }
      end
    end

    describe "when initialize with a tiny probability" do
      before do
        @bonus_pool = FactoryGirl.create( :bonus_pool )
        @bonus = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.00001 )
        @bonus.left_count.clear
        @bonus.update_left_count_in_redis!
        @bonus_pool.update_digit_pool!
      end
    
      context "when count total size of digit_pool" do
        subject do
          @bonus_pool.update_digit_pool!
          @bonus_pool.digit_pool
        end
        its(:length){should == 200000 }
      end
    end

    describe "when total probability greater than 1" do
      before do
        @bonus_pool = FactoryGirl.create( :bonus_pool )
        @bonus1 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.7 )
        @bonus2 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.8 )
        @bonus_pool.digit_pool.clear 
        @bonus1.left_count.clear
        @bonus2.left_count.clear
        @bonus1.update_left_count_in_redis!
        @bonus2.update_left_count_in_redis!
      end
      context "when count total size of digit_pool" do
        subject{ @bonus_pool.update_digit_pool! }
        its( "digit_pool.length" ){should == 22500}
      end
      context "when count specified size of each bonus1" do
        subject do
            @bonus_pool.update_digit_pool!
            @bonus_pool.digit_pool.values.select{|at| at == @bonus1.code} 
        end
        its(:size){should == 10500 }
      end
      context "when count specified size of each bonus2" do
        subject do
          @bonus_pool.update_digit_pool!
          @bonus_pool.digit_pool.values.select{|at| at == @bonus2.code}
        end
        its(:size){should == 12000 }
      end
    end


  end

  describe BonusPool , "#play!" do
    describe "when sum probability less than 1" do
      before do
        @bonus_pool = FactoryGirl.create( :bonus_pool )
        @bonus1 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.1 , :count => 1000)
        @bonus2 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.2 , :count => 1000)
        @bonus_pool.digit_pool.clear 
        @bonus1.left_count.clear
        @bonus2.left_count.clear
        @bonus1.update_left_count_in_redis!
        @bonus2.update_left_count_in_redis!
        @bonus_pool.update_digit_pool!
      end
      context "when play by 1000 times" do
        context "when count result link to bonus1" do
          subject do
            1000.times.map{ @bonus_pool.play! }.select{|code| code == @bonus1.code }
          end
          its( "size" ){should be_between 85 , 115}
        end
        context "when count result link to bonus2" do
          subject do
            1000.times.map{ @bonus_pool.play! }.select{|code| code == @bonus2.code }
          end
          its( "size" ){should be_between 180 , 220}
        end
      end

    end

    describe "when sum probability greater than 1" do
      before do
        @bonus_pool = FactoryGirl.create( :bonus_pool )
        @bonus1 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.7  , :count => 1000)
        @bonus2 = FactoryGirl.create( :bonus , :bonus_pool => @bonus_pool , :probability => 0.8  , :count => 1000)
        @bonus_pool.digit_pool.clear
        @bonus1.left_count.clear
        @bonus2.left_count.clear
        @bonus1.update_left_count_in_redis!
        @bonus2.update_left_count_in_redis!
        @bonus_pool.update_digit_pool!
      end
      context "when play by 1500 times" do
        context "when count result link to bonus1" do
          subject do
            1500.times.map{ @bonus_pool.play! }.select{|code| code == @bonus1.code }
          end
          its( "size" ){should be_between( 680 , 720) }
        end
        context "when count result link to bonus2" do
          subject do
            1500.times.map{ @bonus_pool.play! }.select{|code| code == @bonus2.code }
          end
          its( "size" ){should be_between 780 , 820}
        end
      end

    end
  end
end
