class CreateDonors < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.string :name
      t.string :stripe_customer_id, :string
      t.string :address
      t.string :city
      t.string :state, limit: 2
      t.string :zip, limit: 10
      t.string :phone_number, limit: 24
      t.timestamps
    end
  end
end
