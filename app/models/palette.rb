class Palette < ActiveRecord::Base
  attr_accessible :color_id, :dotimage_id, :position_x, :position_y
  belongs_to :color
  belongs_to :dotimage
end
