class Donor < ActiveRecord::Base
	
	has_many :donations
  has_many :users, :as => :role
  has_and_belongs_to_many :campaigns

  def first_donation_date(endowment_id)
    self.donations.where("endowment_id = ?", endowment_id).order("created_at ASC").first.created_at.to_date rescue Date.today
  end

  def charity_balance_on(charity_id, date)
    dt = DateTime.parse(date.to_s)
    dt = dt + 11.hours + 59.minutes + 59.seconds
    (self.donations.where("charity_id = ? AND created_at <= ?", charity_id, dt).sum(:net_amount) - self.grants.where("charity_id = ? AND created_at <= ? AND (status = ? OR status = ?)", charity_id, dt, 'accepted', 'pending_acceptance').sum(:grant_amount)).floor2(2)
  end

  def my_balances(endowment_id)

    last_donation_price = Share.last.donation_price rescue 0.0

    my_balance_history = (first_donation_date(endowment_id)..Date.today).select {|d| (d.day % 7) == 0 || d==Date.today}.map { |date| {"date"=>date, "balance"=>self.endowment_balance_on(endowment_id, date)} }

    is_subscribed = false

    begin
      my_subscription_row = self.donor_subscriptions.where("endowment_id = ? AND canceled_at IS NULL", endowment_id).last
      is_subscribed = true
      my_subscription_id = my_subscription_row.id
      my_subscription_amount = my_subscription_row.gross_amount
      my_subscription_type = my_subscription_row.type_subscription
      my_subscription_canceled_at = my_subscription_row.canceled_at
    rescue
      is_subscribed = false
    end

    my_donations = self.donations.where("endowment_id = ?", endowment_id)
    my_grants = self.grants.where("endowment_id = ? AND status !='reclaimed'", endowment_id)

    my_donations_count = my_donations.count('id', :distinct => true)
    my_donations_amount = my_donations.sum(:gross_amount)
    my_donations_shares = my_donations.sum(:shares_added)

    my_grants_amount = my_grants.where("(status = ? OR status = ?)", 'accepted', 'pending_acceptance').sum(:grant_amount)
    my_grants_shares = my_grants.where("(status = ? OR status = ?)", 'accepted', 'pending_acceptance').sum(:shares_subtracted)

    my_balance_pre_investment = my_donations_amount - my_grants_amount
    my_endowment_share_balance = my_donations_shares - my_grants_shares

    my_endowment_balance = (my_endowment_share_balance * last_donation_price).floor2(2)
    
    my_investment_gainloss = (my_endowment_balance - my_balance_pre_investment).floor2(2)

    if defined?(:my_donations_count) && my_donations_count > 0
      my_investment_gainloss_percentage = (my_investment_gainloss / my_donations_amount * 100).floor2(2)
    else
      my_investment_gainloss_percentage = 0.0
    end

    {
      "is_subscribed" => is_subscribed,
      "my_subscription_id" => my_subscription_id || "",
      "my_subscription_amount" => my_subscription_amount.to_f || 0.0,
      "my_subscription_type" => my_subscription_type || "",
      "my_subscription_canceled_at" => my_subscription_canceled_at || "",

      "my_donations_count" => my_donations_count || 0,
      #"my_donations_shares" => my_donations_shares, # We should not expose shares to users -- too confusing
      "my_donations_amount" => my_donations_amount.to_f || 0,
      #"my_grants_shares" => my_grants_shares,
      "my_grants_amount" => my_grants_amount.to_f || 0,
      "my_balance_history" => my_balance_history || 0,

      "my_balance_pre_investment" => my_balance_pre_investment.to_f || 0,
      #"my_endowment_share_balance" => my_endowment_share_balance,

      "my_investment_gainloss" => my_investment_gainloss.to_f || 0,
      "my_investment_gainloss_percentage" => my_investment_gainloss_percentage || 0,
      "my_endowment_balance" => my_endowment_balance.to_f || 0
    }
  end

end
