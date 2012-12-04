class Color < ActiveRecord::Base
  attr_accessible :b, :hex, :g, :name, :r
  has_many :palettes
end
