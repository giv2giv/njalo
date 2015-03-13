class CharityCampaignsController < ApplicationController

  before_action :set_campaign, only: [:show, :stripe, :dwolla, :widget_data]

	respond_to :html, :json

  def index
    if params[:query].present?
      @charities = CharityCampaign.search(params[:query], page: params[:page], limit:25)
    else
      @charities = CharityCampaign.all.page params[:page]
    end
    respond_with(@charities)  #this is better right?
#    respond_to do |format|
#      format.html
#      format.js
#    end
  end

  def autocomplete
    render json: CharityCampaign.search(params[:query], fields: [{name: :text_start}], limit: 15).map(&:name)
  end

  def show
    respond_with(@campaign)
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
      charity_campaign_id: @campaign.id,
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

      donation = Donation.add_donation(donor.id, transaction['destinationTransaction'], gross_amount, transaction_fee, net_amount)

      render json: my_donation.to_json # or redirect_to since we've grabbed the browser?

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
    @campaign = CharityCampaign.new(campaign_params)
    @campaign.save
    respond_with(@campaign)
  end

  private
    def set_campaign
      @campaign = CharityCampaign.where("(njalo_id=? OR slug=?)", params[:id], params[:id]).last
    end

    def campaign_params
    	#Do something better here
#      params.require(:campaign).permit(:user_id, :payment_account_id, :charity_id, :processor_subscription_id, :type_subscription, :gross_amount, :canceled_at)

      #params[:campaign]
    end

    def createRandomEmail
      require 'securerandom'
      SecureRandom.hex + "@njalo.org";
    end
end