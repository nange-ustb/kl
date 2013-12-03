# -*- encoding : utf-8 -*-
class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :title
      t.string :ancestry
      t.boolean :is_child,:default=>false

      t.timestamps
    end
    add_index :keywords,[:ancestry]
  end
end
