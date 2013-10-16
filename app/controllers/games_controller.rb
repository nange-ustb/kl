# -*- encoding : utf-8 -*-
class BonusPoolsController < ApplicationController

  def show
    if @bonus_pool = BonusPool.find( params[:id] )
      @bonus_code = @bonus_pool.play!
    end
    respond_to do |format|
      format.json { render :json => [ @bonus_code ] }
    end
  end

  def update
    if @bonus_pool = BonusPool.find( params[:id] )
      @bonus_code = @bonus_pool.play!
    end
    respond_to do |format|
      format.json { render :json => [ @bonus_code ] }
    end
  end
end
