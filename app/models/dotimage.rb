class Dotimage < ActiveRecord::Base
  attr_accessible :name, :resized_image
  has_attached_file :resized_image, :styles => {:small => "32x32>", :new_image => "32x32>", :enlarge => "320x320"}

  def distance
  end

  def palette
  end
end
