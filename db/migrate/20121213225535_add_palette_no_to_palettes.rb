class AddPaletteNoToPalettes < ActiveRecord::Migration
  def change
    add_column :palettes, :palette_no, :integer
  end
end
