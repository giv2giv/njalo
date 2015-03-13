class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :donor_id,                  null: false
      t.integer :campaign_id,                  null: false
      t.decimal :gross_amount,           precision: 30, scale: 2, null: false
      t.decimal :shares_added,                  null: false
      t.decimal :transaction_fee,           precision: 30, scale: 2, null: false
      t.decimal :net_amount,           precision: 30, scale: 2, null: false
      t.string  :processor_transaction_id,                  null: false
      t.string  :status,  null: false, default: 'pending'
      t.timestamps
    end
  end
end
