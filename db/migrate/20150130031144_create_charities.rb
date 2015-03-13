class CreateCharities < ActiveRecord::Migration
  def change
    create_table :charities do |t|
	    t.string   "name"
	    t.string   "display_name"
	    t.string   "ein",                            null: false
	    t.string   "care_of"
	    t.string   "address"
	    t.string   "city"
	    t.string   "state"
	    t.string   "zip"
	    t.string	 "group_code"
	    t.string	 "affiliation_code"
	    t.string   "ntee_code"
	    t.date     "ruling_date"
	    t.string   "classification_code"
	    t.string   "deductibility_code"
	    t.string   "foundation_code"
	    t.string   "subsection_code"
	    t.string   "activity_code"
	    t.string   "organization_code"
	    t.string   "status_code"
	    t.string   "asset_code"
	    t.string   "income_code"
	    t.string   "filing_requirement_code"
	    t.string   "pf_filing_requirement_code"
	    t.date  	 "tax_period"
	    t.string   "accounting_period"
	    t.integer  "asset_amount",  			limit: 8
	    t.integer  "income_amount",  			limit: 8
	    t.integer  "revenue_amount",  			limit: 8
	    t.string   "description"
	    t.string   "website"
	    t.datetime "created_at",                     null: false
	    t.datetime "updated_at",                     null: false
	    t.boolean  "active"
	    t.float    "latitude",            limit: 24
	    t.float    "longitude",           limit: 24
	    t.string   "slug"
      t.timestamps
    end
    add_index :charities, :ein,                 unique: true
    add_index :charities, :slug,                unique: true
  end
end
