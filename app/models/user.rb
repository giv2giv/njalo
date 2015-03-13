class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :confirmable,
     			:omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :linkedin, :dwolla]

  has_many :authorizations
  has_many :campaigns

  belongs_to :role, polymorphic: true

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    begin #wrap these all in a transaction
      authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
      if authorization.user.blank?
        user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
        if user.blank?
          user = User.new
          user.password = Devise.friendly_token[0,10]
          user.name = auth.info.name
          user.email = auth.info.email
          user.skip_confirmation!
          user.save!
        end
        authorization.username = auth.info.nickname
        authorization.user_id = user.id
        authorization.save
      end
    end
    authorization.user
  end

end
