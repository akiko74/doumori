class Dotimage < ActiveRecord::Base
  attr_accessible :name, :resized_image
  has_attached_file :resized_image, :styles => { :small => ["32x32#", :png],:new_image => ["32x32#", :png], :enlarge => "320x320"},
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :path => ":attachment/:id/:style.:extension"

  validates_attachment_content_type :resized_image, :content_type => ["image/jpeg", "image/jpg", "image/gif", "image/png"]
  validates_attachment_size :resized_image, :less_than => 300.kilobytes
  has_many :palettes, :dependent => :delete_all, :validate => false

  def distance
  end

  def set_cube(palette)
  end
end
