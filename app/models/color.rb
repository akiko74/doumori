class Color < ActiveRecord::Base
  attr_accessible :b, :g, :name, :r
  has_many :palettes
end
