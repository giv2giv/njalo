json.array!(@users) do |user|
  json.extract! user, :id, :name, :accepted_terms, :accepted_terms_on, :address, :city, :state, :zip, :phone_number, :type_user
  json.url user_url(user, format: :json)
end
