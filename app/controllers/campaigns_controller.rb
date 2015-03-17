class CampaignsController < ApplicationController

  before_action :set_campaign, only: [:show, :edit, :update, :stripe, :dwolla, :widget_data]

	respond_to :html, :json

  def index
    if params[:q].present?
      @campaigns = Campaign.search(params[:q], page: params[:page], limit:25)
    else
      @campaigns = Campaign.all.page params[:page]
    end
    respond_with(@campaigns)  #this is better right?
#    respond_to do |format|
#      format.html
#      format.js
#    end
  end

  def prefetch_data
    respond_with(Campaign.all.limit(100))
  end

  def autocomplete
    render json: Campaign.search(params[:q], fields: [{name: :word_start}], limit: 30).map {|campaign| {value: campaign.name, id: campaign.id}}
  end

  def near
    radius = (params[:radius] || 25).to_i
    @campaigns = []

    if radius > 100
      radius = 100
    end

    location_by_ip = request.location

    if location_by_ip.latitude==0.0
      params[:latitude] = '38.149576'
      params[:longitude] = '-79.0716958'
    end

    if params.has_key?(:latitude) && params.has_key?(:longitude)
      @charities = Charity.near([params[:latitude].to_f, params[:longitude].to_f], radius, :order => "distance").limit(100)
    else
      @charities = Charity.near([location_by_ip.latitude, location_by_ip.longitude], radius, :order => "distance").limit(100)
    end

    if @charities.present?      
      @charities.each do |charity|
        charity.campaigns.each do |campaign|
          @campaigns << campaign
        end
      end
    end

    respond_with(@charities.includes(:campaigns))
  end

  def show
    @campaign
  end

  # GET /campaign/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaign/1/edit
  def edit
    @campaign
  end

  # PATCH/PUT /campaign/1
  # PATCH/PUT /campaign/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end


	def stripe
    amount =  params.fetch(:'njalo-amount') { raise 'njalo-amount required' }
    stripeToken = params.fetch(:'njalo-stripeToken') { raise 'njalo-stripeToken required' }

    amount = (amount.to_f * 100).to_i
    email = params[:'njalo-email'].present? ? params[:'njalo-email'] : createRandomEmail

    begin

    # Create a Customer
    customer = Stripe::Customer.create(
      :source => stripeToken,
      :email  => email,
      :description => "widget"
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => amount,
      :description => "njalo donation to " + @campaign.name,
      :currency    => 'usd'
    )

    user = User.where(:email => email).first_or_initialize
    user.skip_confirmation!
    user.skip_validation!
    user.save!(:validate => false)

    if user.donor_id?
      donor = user.role
    else
      donor = create!(:name=>'Unknown')
    end
    donor.stripe_customer_id = customer.id
    donor.save!

    transaction = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)

    gross_amount = BigDecimal(transaction.amount.to_s) / 100
    transaction_fee = BigDecimal(transaction.fee.to_s) / 100
    net_amount = BigDecimal(transaction.net.to_s) / 100

    donation = Donation.add_donation(
      donor_id: donor.id,
      campaign_id: @campaign.id,
      transaction_id: transaction.id.to_s,
      gross_amount: gross_amount,
      transaction_fee: transaction_fee,
      net_amount: net_amount
    )

    render json: donation.to_json

    rescue Stripe::CardError => e
      # The card has been declined
    rescue #ActiveRecord::ActiveRecordError #rescue most everything else
      # Problem with DB
    end
  end

  def dwolla

    Dwolla::OffsiteGateway.clear_session

    # Set API credentials
    Dwolla::api_key = App.dwolla['api_key']
    Dwolla::api_secret = App.dwolla['api_secret']

    Dwolla::sandbox = true
    mail = params[:'njalo-email'].present? ? params[:'njalo-email'] : createRandomEmail

    # Where should Dwolla send the user after they check out or cancel?
    Dwolla::OffsiteGateway.redirect = App.njalo['url'] + "/campaigns/#{@campaign.id}/dwolla_done"

    # Add a product to the purchase order
    Dwolla::OffsiteGateway.add_product(@campaign.name, "njalo donation to " + @campaign.name, params[:'njalo-amount'].gsub(/[^\d\.]/, '').to_f, 1)

    # Generate a checkout URL payable to our Dwolla ID
    checkout_url = Dwolla::OffsiteGateway.get_checkout_url(App.dwolla['account_id'])
    redirect_to checkout_url
  end

  def dwolla_done

#callback comes in
#  create donation, mark as 'pending'

#  Split pass-thru
#  if immediate, send pass-thru - x%

#receive webhook
#  mark as correct status
#  if !immediate, send pass-thru

    Dwolla::OffsiteGateway.clear_session

    # Set API credentials
    Dwolla::api_key = App.dwolla['api_key']
    Dwolla::api_secret = App.dwolla['api_secret']
    Dwolla::sandbox = App.dwolla['sandbox']

=begin Callback params looks like:
      "signature"=>"77dbd9d237cc8bce5bd2425c2eb88b435752a788",
      "orderId"=>"",
      "amount"=>"5.00",
      "checkoutId"=>"3c98a679-2795-4dda-a0c2-6b712831c944",
      "status"=>"Completed",
      "clearingDate"=>"2015-02-11T02:27:37Z",
      "sourceEmail"=>"mblinn@gmail.com",
      "sourceName"=>"John Doe",
      "transaction"=>"834644",
      "destinationTransaction"=>"834643",
      "action"=>"dwolla_done",
      "controller"=>"charities",
      "id"=>"1"
=end

    transaction = Dwolla::OffsiteGateway.read_callback(params.to_json)

    email = transaction['sourceEmail']
    gross_amount = BigDecimal(transaction['amount'])
    
    transaction_fee = gross_amount > 10 ? 0.25 : 0.0
    net_amount = gross_amount - transaction_fee;
    
    begin
      user = User.where(:email => email).first_or_initialize
      user.skip_confirmation!
      user.save!(:validate => false)

      donation = Donation.add_donation(
        donor_id: donor.id,
        campaign_id: @campaign.id,
        transaction_id: transaction.id.to_s,
        gross_amount: gross_amount,
        transaction_fee: transaction_fee,
        net_amount: net_amount
      )
      render json: donation.to_json # or redirect_to since we've grabbed the browser?

      rescue Dwolla::APIError => e
        Rails.logger.debug 'oops'
        # User pressed cancel
      rescue #ActiveRecord::ActiveRecordError #rescue most everything else
        # Problem with DB
    end

  end

  def widget_data
    render json: @campaign
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.save
    respond_with(@campaign)
  end

  private
    def set_campaign
      @campaign = Campaign.where("(id=? OR slug=?)", params[:id], params[:id]).last
    end

    def campaign_params
    	#Do something better here
      params.require(:campaign).permit(:name, :initial_donation_amount, :initial_passthru_percent)

      #params[:campaign]
    end
    def createRandomEmail
      require 'securerandom'
      SecureRandom.hex + "@njalo.org";
    end
end