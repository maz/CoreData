class Product < ActiveRecord::Base
  attr_accessible :name, :price, :description, :person_id
  
  belongs_to :person, :class_name => "Person", :foreign_key => "person_id"
end
