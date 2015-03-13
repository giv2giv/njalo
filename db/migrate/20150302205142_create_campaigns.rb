class CreateCampaigns < ActiveRecord::Migration
  def change

    create_table :campaigns do |t|
      t.string :name, null: false
      t.belongs_to :user
      t.string :tagline
      t.text :description
      t.integer :minimum_donation_amount, default: 5, limit: 2 #See https://ariejan.net/2009/08/20/once-and-for-all-rails-migrations-integer-limit-option/
      t.integer :maximum_donation_amount, default: 1000, limit: 2
      t.integer :minimum_passthru_percentage, default: 0, limit: 1
      t.integer :maximum_passthru_percentage, default: 0, limit: 1
      t.integer :initial_donation_amount, default: 25, limit: 2
      t.integer :initial_passthru_percent, default: 50, limit: 1
      t.boolean :initial_donor_assumes_fees, default: true
      t.string  :widget_callback_url
      t.string :slug, index: true, unique: true
      t.timestamps
    end

    #Donor has_and_belongs_to_many :campaigns
    create_table :campaigns_donors, id: false do |t|
      t.belongs_to :campaign, null: false, index: true
      t.belongs_to :donor, null: false, index: true
      t.timestamps
    end

    add_index :campaigns_donors, [:campaign_id, :donor_id], name: :champaigns_donors_compound, unique: true

    #Now add charities to campaigns
    create_table :campaigns_charities, id: false do |t|
      t.belongs_to :campaign, null: false, index: true
      t.belongs_to :charity, null: false, index: true
      t.timestamps
    end

    add_index :campaigns_charities, [:campaign_id, :charity_id], name: :campaigns_charities_compound, unique: true

  end
end
