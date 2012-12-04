class AddPaletteToDotimages < ActiveRecord::Migration
  def change
    add_column :dotimages, :palette, :string
  end
end
