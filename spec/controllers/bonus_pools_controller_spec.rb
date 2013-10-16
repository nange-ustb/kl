# -*- encoding : utf-8 -*-
require 'spec_helper'

describe BonusPoolsController do

  describe BonusPoolsController , "#update" do
    before{ init_a_level }
    context "when PUT update to play lottery as json format" do
      before{ put  :update , :id => @bonus_pool.code , :format => :json }
      subject{ response }
      it{ should be_success }
    end
  end

end
