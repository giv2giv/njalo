class Tag < ActiveRecord::Base

  has_and_belongs_to_many :charities

  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }

  searchkick text_start: ['name']

end
