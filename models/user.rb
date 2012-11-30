class User < ActiveRecord::Base
  attr_accessible :name, :time_zone, :utc_offset

  validates_presence_of :name

  has_many :authentications, :dependent => :destroy
  has_many :articles, :dependent => :destroy


  def self.find_or_create_from_auth_hash(auth, user = nil)

    # Create user if current_user is nil
    user ||= User.create!(  :name => auth[:info][:name],
                            :location => auth[:info][:location],
                            :time_zone => auth[:extra][:raw_info][:time_zone],
                            :utc_offset => auth[:extra][:raw_info][:utc_offset]
                            )

    # Create authentication
    authentication = Authentication.new
    authentication.user = user
    authentication.uid = auth[:uid]
    authentication.provider = auth[:provider]
    authentication.save!

    user
  end
end