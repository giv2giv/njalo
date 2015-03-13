class DwollaLibs
  
  require 'dwolla'

  API_KEY = App.dwolla["api_key"]
  API_SECRET = App.dwolla["api_secret"]
  TOKEN = App.dwolla["company_token"]
  PIN = App.dwolla["pin_account"]
  ACC_ID = App.dwolla["account_id"] 
  GRANT_SOURCE_ACCOUNT = App.dwolla["grant_source_account"]

  Dwolla::api_key = API_KEY
  Dwolla::api_secret = API_SECRET
  Dwolla::token = TOKEN

  def get_balance
    Dwolla::Balance.get
  end

  def get_contact
    Dwolla::Contacts.get
  end

  def search_contact(name)
    Dwolla::Contacts.get({:search => name})
  end

  def contact_nearby(lat, long)
    Dwolla::Contacts.nearby({:latitude => lat, :longitude => lang})
  end

  def get_user
    Dwolla::Users.get
  end

  def get_transactions_last_60_days
    transaction_hash = []
    transactions = Dwolla::Transactions.get({:sinceDate =>(Date.today - 60.days).to_s, :types => 'money_sent', :limit => 200})
    transaction_hash << transactions
    
    while transactions.count.to_i == 200 do
      i += 1
      transactions = Dwolla::Transactions.get({:sinceDate =>(Date.today - 60.days).to_s, :types => 'money_sent', :limit => 200, :skip => (i * 200)})
      transaction_hash << transactions
    end
    transaction_hash[0]
  end

  def get_all_transactions
    Dwolla::Transactions.get
  end

  def get_detail_transaction(transactionId)
    Dwolla::Transactions.get(transactionId)
  end

  def dwolla_send(email, notes = "", amount=nil)
    begin
      #transactionId = Dwolla::Transactions.send({:destinationId => email, :pin => PIN, :destinationType => 'email', :amount => amount, :notes => notes, :fundsSource => GRANT_SOURCE_ACCOUNT})
      transactionId = Dwolla::Transactions.send({:destinationId => email, :pin => PIN, :destinationType => 'email', :amount => amount, :notes => notes })
      return transactionId
    rescue Dwolla::APIError => error
      return error
    end
  end

  def dwolla_webhook
    # Handles Dwolla's Webhook Notification (equivalent to PayPal IPN)
    provided_signature = request.headers['X-Dwolla-Signature']

    # check the webhook's signature.  if validation fails, return 401 and exit
    begin
      Dwolla::OffsiteGateway.validate_webhook(provided_signature, request.raw_post)
    rescue Dwolla::APIError => e
      render :text => "Bad signature.", :status => 401 and return
    end
 
    # parse the webhook JSON body
    webhook = JSON.load(request.raw_post)
    
    if webhook['Status']=="Paid"
      #mark donation as processed
      transaction_id = webhook['Transaction']['Id']
      donation = Donation.where("transaction_id = ?", transaction_id)
      donation.status='processed'
      donation.save!
    end
    render :status => 200, :nothing => true
  end


  def request_cancel(request_id)
    Dwolla::Request.cancel(request_id)
  end

end