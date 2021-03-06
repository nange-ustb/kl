# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::BonusPoolsController do
  before(:each){ 2.times{ init_a_level } }
  describe Admin::BonusPoolsController , "#index" do
    context "when GET 'admin/bonus_pools'" do
      before{ get :index , :format => :json }
      subject{ response }
      it{ should be_success }
      specify{ assigns( :bonus_pools ).should have(2).elements }
    end
  end
  
  describe Admin::BonusPoolsController , "#show" do
    context "when GET 'admin/bonus_pools/#id'" do
      before{ get :show , :id => @bonus_pool.code , :format => :json }
      subject{ response }
      it{ should be_success }
      specify do
        assigns( :bonus_pool ).should_not be_nil
      end
    end
  end
  
  describe Admin::BonusPoolsController , "#update" do
    context "when PUT 'admin/bonus_pools/#id' with a new award pool" do
      before do
        digit_pool_list = bonus_counter = ::Redis::List.new( "#{Rails.env}/bonus_pool/aaa" , ::BonusPool.redis, ::BonusPool.redis_objects[:digit_pool])
        digit_pool_list.clear
        put :update , :id => @bonus_pool.code ,
            :award_pools => [{ :code => "aaa" , :count => 10 , :probability => 0.1 }] ,
            :format => :json
      end
      subject{ response }
      it{ should be_success }
      specify do
        assigns( :bonus_pool ).should_not be_nil
        assigns( :bonus_pool ).digit_pool.values.select{|_| _== "aaa" }.should have(1000).elements
        Bonus.should be_exists( :bonus_pool_id => @bonus_pool.id , :code => "aaa" , :count => 10 , :probability => 0.1 )
        bonus = Bonus.where( :bonus_pool_id => @bonus_pool.id , :code => "aaa" , :count => 10 , :probability => 0.1 ).first
        bonus.left_count.value.should == 10

      end
    end
  
    context "when PUT 'admin/bonus_pools/#id' with a existed award pool" do
      before do
        @update_bonus = @bonus_pool.bonuses.sample
        put :update , :id => @bonus_pool.code , 
              :award_pools => [{ :code => @update_bonus.code , :count => 99 , :probability => 0.2 }] ,
              :format => :json 
      end
      subject{ response }
      it{ should be_success }
      specify do
        assigns( :bonus_pool ).should_not be_nil
        assigns( :bonus_pool ).digit_pool.values.select{|_| _== @update_bonus.code }.should have(2000).elements
        Bonus.should be_exists( :bonus_pool_id => @bonus_pool.id , :count => 99 , :probability => 0.2 )
        bonus = Bonus.where( :bonus_pool_id => @bonus_pool.id , :code => @update_bonus.code , :count => 99 , :probability => 0.2 ).first
        bonus.left_count.value.should == 99
      end
    end
  end

  describe Admin::BonusPoolsController , "#create" do
    context "when POST 'admin/bonus_pools'" do
      before do
        digit_pool_list1 = bonus_counter = ::Redis::List.new( "#{Rails.env}/bonus_pool/aaa" , ::BonusPool.redis, ::BonusPool.redis_objects[:digit_pool])
        digit_pool_list1.clear
        digit_pool_list2 = bonus_counter = ::Redis::List.new( "#{Rails.env}/bonus_pool/bbb" , ::BonusPool.redis, ::BonusPool.redis_objects[:digit_pool])
        digit_pool_list2.clear

        post :create ,
            :code => "code_new" ,
            :award_pools => [
              { :code => "aaa" , :count => 10 , :probability => 0.5 },
              { :code => "bbb" , :count => 100 , :probability => 0.3 }
            ] ,
            :format => :json 
      end
      subject{ response }
      it{ should be_success }
      specify do
        assigns( :bonus_pool ).should_not be_nil
        assigns( :bonus_pool ).digit_pool.values.select{|_| _== "aaa" }.should have(5000).elements
        assigns( :bonus_pool ).digit_pool.values.select{|_| _== "bbb" }.should have(3000).elements
        Bonus.should be_exists( :bonus_pool_id => BonusPool.last.id , :code => "aaa" , :count => 10 , :probability => 0.5 )
        bonus1 = Bonus.where( :bonus_pool_id => BonusPool.last.id , :code => "aaa" , :count => 10 , :probability => 0.5 ).first
        bonus1.left_count.value.should == 10
        Bonus.should be_exists( :bonus_pool_id => BonusPool.last.id , :code => "bbb" , :count => 100 , :probability => 0.3 )
        bonus2 = Bonus.where( :bonus_pool_id => BonusPool.last.id , :code => "bbb" , :count => 100 , :probability => 0.3 ).first
        bonus2.left_count.value.should == 100
      end
    end
  end

  describe Admin::BonusPoolsController , "#destroy" do
    context "when DELETE 'admin/bonus_pools/1'" do
      before{ delete :destroy , :id => @bonus_pool.code , :format => :json }
      subject{ response }
      it{ should be_success }
      specify do
        BonusPool.should_not be_exists( :code => @bonus_pool.code )
        Bonus.should_not be_exists( :bonus_pool_id => @bonus_pool.id )
      end
    end
  end

end
