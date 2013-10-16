# -*- encoding : utf-8 -*-
class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :code
      t.string :title

      t.timestamps
    end
    add_index :games, :code
  end
end
