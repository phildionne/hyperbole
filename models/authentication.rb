class Authentication < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.create_from_user_and_auth!(user, auth)
    authentication = self.new
    authentication.user = user
    authentication.uid = auth[:uid]
    authentication.provider = auth[:provider]
    authentication.save!
  end
end