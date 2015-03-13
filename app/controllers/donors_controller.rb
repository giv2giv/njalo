class DonorsController < ApplicationController
  before_action :set_donor, only: [:show, :edit, :update, :destroy]

  # GET /donors
  # GET /donors.json
  def index
    @donors = Donor.all
  end

  # GET /donors/1
  # GET /donors/1.json
  def show
  end

  # GET /donors/new
  def new
    @donor = Donor.new
  end

  # GET /donors/1/edit
  def edit
  end

  # POST /donors
  # POST /donors.json
  def create
    @donor = Donor.new(donor_params)

    respond_to do |format|
      if @donor.save
        DonorMailer.create_donor(donor.email, donor.name)
        require 'gibbon'
        gb = Gibbon::API.new(App.mailer['mailchimp_key'])
        gb.lists.subscribe({:id => App.mailer['mailchimp_list_id'], :email => {:email => donor.email}, :merge_vars => {:FNAME => donor.name}, :double_optin => false})
        invite = Invite.where("hash_token = ?", params[:hash_token])
        if invite
          invite.accepted = true
          invite.save!
        end
        format.html { redirect_to @donor, notice: 'Donor was successfully created.' }
        format.json { render :show, status: :created, location: @donor }
      else
        format.html { render :new }
        format.json { render json: @donor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /donors/1
  # PATCH/PUT /donors/1.json
  def update
    respond_to do |format|
      if @donor.update(donor_params)
        format.html { redirect_to @donor, notice: 'Donor was successfully updated.' }
        format.json { render :show, status: :ok, location: @donor }
      else
        format.html { render :edit }
        format.json { render json: @donor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donors/1
  # DELETE /donors/1.json
  def destroy
    @donor.destroy
    respond_to do |format|
      format.html { redirect_to donors_url, notice: 'Donor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donor
      @donor = Donor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donor_params
      params.require(:donor).permit(:name, :email, :accepted_terms, :accepted_terms_on, :address, :city, :state, :zip, :phone_number, :type_donor)
    end
end