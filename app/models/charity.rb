class Charity < ActiveRecord::Base

  has_many :users, :as => :role
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :campaigns

  validates :ein, :presence => true, :uniqueness => true
  validates :name, :presence => true

	geocoded_by :full_street_address

  #geocode on save if address changed
  #after_validation :geocode, if: ->(charity){ charity.address.present? and charity.address_changed? }
  #geocode on load if charity not yet geocoded
  #after_find :geocode, if: ->(charity){ charity.address.present? and charity.latitude.nil? }
  #after_initialize do |charity|
    #if charity.latitude_changed?
      #charity.save!
    #end
  #end

  searchkick text_start: ['name']

  def search_data
    {
      name: name#,
      #tag_name: self.tags.map(&:name)
    }
  end


  extend FriendlyId
  friendly_id :name, use: :slugged
  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :address, :city],
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def full_street_address
    [self.address,self.city,self.state,self.zip].join(' ').squeeze(' ')
  end

end
