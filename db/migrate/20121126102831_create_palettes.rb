class CreatePalettes < ActiveRecord::Migration
  def change
    create_table :palettes do |t|
      t.integer :dotimage_id
      t.integer :position_x
      t.integer :position_y
      t.integer :color_id

      t.timestamps
    end
  end
end
