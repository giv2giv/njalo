class Campaign < ActiveRecord::Base

  has_and_belongs_to_many :tags
  has_many :donations
  has_many :grants
  belongs_to :user

  has_and_belongs_to_many :donors
  has_and_belongs_to_many :charities

  validates :name, :presence => true

  searchkick word_start: [:name], callbacks: :async

  def search_data
    {
      name: name#,
#      tag_name: tags.map(&:name)
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
  
end