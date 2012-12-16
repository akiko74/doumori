class Palette < ActiveRecord::Base
  attr_accessible :color_id, :dotimage_id, :position_x, :position_y, :palette_no
  belongs_to :color
  belongs_to :dotimage
end
