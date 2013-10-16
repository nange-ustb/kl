# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  is_child   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Keyword do
  pending "add some examples to (or delete) #{__FILE__}"
end
