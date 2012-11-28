class Authorization < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  protected

  def self.find_from_auth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid'])
  end

  def self.create_from_auth(auth, user = nil)
    user ||= User.create_from_auth!(auth)
    Authorization.create(:user_id => user.id, :uid => auth['uid'], :provider => auth['provider'])
  end
end