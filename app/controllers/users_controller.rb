class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update]
  before_filter :validate_authorization_for_user, only: [:edit, :update]

  def create

    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        UserMailer.create_user(user.email)
        require 'gibbon'
        gb = Gibbon::API.new(App.mailer['mailchimp_key'])
        gb.lists.subscribe({:id => App.mailer['mailchimp_list_id'], :email => {:email => user.email}, :merge_vars => {:FNAME => user.role.name}, :double_optin => false})
        invite = Invite.where("hash_token = ?", params[:hash_token])
        if invite
          invite.accepted = true
          invite.save!
        end
        format.html { redirect_to @user, notice: 'Donor was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end


  # PATCH/PUT /users/1
  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def validate_authorization_for_user
       redirect_to root_path unless @user == current_user
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end

  end