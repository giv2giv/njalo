
class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id,                  null: false
      t.integer :payment_account_id,         null: false
      t.integer :charity_id,                 null: false
      t.string :processor_subscription_id
      t.text :type_subscription
      t.decimal :gross_amount,           precision: 30, scale: 2, null: false
      t.datetime :canceled_at

      t.timestamps
    end
  end
end