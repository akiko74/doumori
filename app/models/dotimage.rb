class Dotimage < ActiveRecord::Base
  attr_accessible :name, :resized_image
  has_attached_file :resized_image, :styles => { :small => ["32x32#", :png],:new_image => ["32x32#", :png], :enlarge => "320x320"}
  has_many :palettes

  def distance
  end

  def set_cube(palette)
  end
end
