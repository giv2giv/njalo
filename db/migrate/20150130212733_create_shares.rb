class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
	    t.decimal  :share_total_beginning,       precision: 30, scale: 20
	    t.decimal  :shares_added_by_donation,    precision: 30, scale: 20
	    t.decimal  :shares_subtracted_by_grants, precision: 30, scale: 20
	    t.decimal  :share_total_end,             precision: 30, scale: 20
	    t.datetime :created_at,                                            null: false
	    t.datetime :updated_at,                                            null: false
	    t.decimal  :stripe_balance,              precision: 10, scale: 2
	    t.decimal  :etrade_balance,              precision: 10, scale: 2
	    t.decimal  :donation_price,              precision: 10, scale: 2
	    t.decimal  :grant_price,                 precision: 10, scale: 2
	    t.timestamps
	  end
  end
end
