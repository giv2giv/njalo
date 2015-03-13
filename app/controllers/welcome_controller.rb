class WelcomeController < ApplicationController

respond_to :html

  def index

    radius = (params[:radius] || 50).to_i
    @campaigns_hash = []

    if params.has_key?(:latitude) && params.has_key?(:longitude)
      charities = Charity.near([params[:latitude].to_f, params[:longitude].to_f], radius, :order => "distance").limit(50)
    else
      location_by_ip = request.location
      charities = Charity.near([location_by_ip.latitude, location_by_ip.longitude], radius, :order => "distance").limit(50)
    end

    if charities.present?
      charities.each do |charity|
        @campaigns_hash << charity.campaigns
      end
    end

    respond_with(@campaigns_hash)


  end
end
