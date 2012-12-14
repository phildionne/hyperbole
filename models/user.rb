class User < ActiveRecord::Base
  attr_accessible :name, :location, :time_zone

  has_many :authentications, :dependent => :destroy
  has_many :articles, :dependent => :destroy

  validates_presence_of :name

  def self.find_or_create_from_auth(auth, user = nil)
    # Create user if current_user is nil
    user ||= User.create!(  :name => auth[:info][:name],
                            :location => auth[:info][:location],
                            :time_zone => auth[:extra][:raw_info][:time_zone] # Fallback to default Time.zone if empty
                            )
    # Create new authentication
    Authentication.create_from_user_and_auth!(user, auth)

    user
  end

  def fullname_or_american_first_name
    name = self.name.split[0] unless self.name.split.count >= 3
    name ||= fullname
  end
end