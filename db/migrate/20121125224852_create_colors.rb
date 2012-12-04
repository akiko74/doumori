class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :name
      t.integer :r
      t.integer :g
      t.integer :b

      t.timestamps
    end
  end
end
