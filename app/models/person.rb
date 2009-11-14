class Person < ActiveRecord::Base
  validates_presence_of :name,:age
  validates_numericality_of :age
  validates_uniqueness_of :name
  
  has_many :products
end
