class Tag < ActiveRecord::Base

  has_and_belongs_to_many :charities
  has_and_belongs_to_many :campaigns

  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }

  searchkick word_start: [:name], callbacks: :async

end
