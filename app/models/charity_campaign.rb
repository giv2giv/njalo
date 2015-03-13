class CharityCampaign < ActiveRecord::Base

  has_many :donations
  has_many :grants
  belongs_to :charity


  before_validation :create_njalo_id, :if => 'self.new_record?'
  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :njalo_id, :uniqueness => true


  searchkick #settings: {number_of_shards: 1}

  def search_data
    {
      name: name#,
      #tag_name: self.tags.map(&:name)
    }
  end

  extend FriendlyId
  friendly_id :name, use: :slugged

  def slug_candidates
    [
      :name,
      [:name, :tagline]
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  private
    def create_njalo_id
      self.njalo_id = SecureRandom.uuid
      self.njalo_id = SecureRandom.uuid until CharityCampaign.find_by_njalo_id(self.njalo_id).nil?
    end
  
end