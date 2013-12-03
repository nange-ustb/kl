# -*- encoding : utf-8 -*-
class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.string :title
      t.string :code
      t.float :probability
      t.integer :count
      t.belongs_to :game

      t.timestamps
    end
    add_index :awards, :game_id
    add_index :awards, :code
  end
end
