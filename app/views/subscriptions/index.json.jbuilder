json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :user_id, :payment_account_id, :charity_id, :processor_subscription_id, :type_subscription, :gross_amount, :canceled_at
  json.url subscription_url(subscription, format: :json)
end
