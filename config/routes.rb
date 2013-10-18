# -*- encoding : utf-8 -*-
LotteryGame::Application.routes.draw do
  resources :games , :path => :levels
  namespace :admin do
  	root :to => "games#index" 
    resources :games , :path => :levels #, :only => [ :show , :update , :create , :destroy , :index ]
  end
end
