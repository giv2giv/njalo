class Donation < ActiveRecord::Base
	belongs_to :donor
	belongs_to :charity
	belongs_to :campaign

	validates_numericality_of :donor_id, allow_nil: false
	validates_numericality_of :campaign_id

  VALID_STATUS = %w(pending denied processed reclaimed failed canceled)
  #Dwolla: 'processed', 'pending', 'cancelled', 'failed', 'reclaimed'
  validates :status, :presence => true, :inclusion => { :in => VALID_STATUS }


	class << self

		def add_donation ( options )

	    shares_added = (BigDecimal("#{net_amount}") / Share.last.donation_price) # donation_price already BigDecimal

	    my_donation = Donation.new { |donation|
	      donation.donor_id = options.donor_id
	      donation.gross_amount = options.gross_amount
	      donation.net_amount = options.net_amount
	      donation.campaign_id=campaign_id
	      donation.transaction_fee = options.transaction_fee
	      donation.processor_transaction_id = options.transaction_id
	      donation.shares_added = shares_added
	      donation.status='pending'
	    }
	    my_donation.save!

		end
	end
end


