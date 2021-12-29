class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :packing_style
      t.integer :length
      t.integer :width
      t.integer :height
      t.float :weight
      t.string :cog_height_type
      t.float :cog_height

      t.timestamps
    end
  end
end
