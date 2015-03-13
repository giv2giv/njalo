class CallbacksController < Devise::OmniauthCallbacksController
  
skip_before_filter :authenticate_user!

  def all
    p env["omniauth.auth"]
    user = User.from_omniauth(env["omniauth.auth"], current_user)
    if user.persisted?
      flash[:notice] = "You are in..!"
      sign_in_and_redirect(user)
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  # we could check to see if the user has entered an email when they use twitter/github/dwolla
  # if no, take to form that makes them enter other info
  # else do what all does.
  # also you broke my infiniscroll :(
  def all_without_email

  end

  def failure
    #handle you logic here..
    #and delegate to super.
    super
  end

  alias_method :facebook, :all
  #alias_method :twitter, :all
  alias_method :linkedin, :all
  #alias_method :github, :all
  alias_method :dwolla, :all
  alias_method :passthru, :all
  alias_method :google_oauth2, :all

end