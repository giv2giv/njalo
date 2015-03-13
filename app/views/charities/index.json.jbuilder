json.array!(@charities) do |charity|
  json.extract! charity, :id
  json.url charity_url(charity, format: :json)
end
