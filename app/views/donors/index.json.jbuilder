json.array!(@donors) do |donor|
  json.extract! donor, :id, :name, :address, :city, :state, :zip, :phone_number
  json.url donor_url(donor, format: :json)
end
