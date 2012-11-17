class Dotimage < ActiveRecord::Base
  attr_accessible :name, :resized_image
  has_attached_file :resized_image, :styles => {:small => "32x32>"}
end
