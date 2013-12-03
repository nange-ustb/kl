# -*- encoding : utf-8 -*-
class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def new
    @game = Game.new
  end

  def show
    if @game = Game.find( params[:id] )
      @code = @game.play!
    end
    if params[:format] == 'json'
      respond_to do |format|
        format.json { render :json => [ @code ] }
      end
    end
  end

  def update
    if @game = Game.find( params[:id] )
      @code = @game.play!
    end
    if params[:format] == 'json'
      respond_to do |format|
        format.json { render :json => [ @code ] }
      end
    end
  end
end
