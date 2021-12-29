class AddColumnToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :height_unit, :string
    add_column :items, :weight_unit, :string
    add_column :items, :cog_height_unit, :string
  end
end
