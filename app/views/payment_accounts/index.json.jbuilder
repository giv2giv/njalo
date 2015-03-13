json.array!(@payment_accounts) do |payment_account|
  json.extract! payment_account, :id, :processor, :user_id, :requires_reauth, :external_account_id, :user_key, :user_pass
  json.url payment_account_url(payment_account, format: :json)
end
