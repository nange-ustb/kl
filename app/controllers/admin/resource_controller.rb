# -*- encoding : utf-8 -*-
require_dependency "application_controller"
class Admin::ResourceController < ApplicationController
  inherit_resources
  has_scope :page, :default => 1 , :unless => :require_complete_data
  
  private
  def require_complete_data
    params[:format] == "xls"
  end
end

