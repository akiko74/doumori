class CreateDotimages < ActiveRecord::Migration
  def change
    create_table :dotimages do |t|
      t.string :name
      t.attachment :resized_image

      t.timestamps
    end
  end
end
