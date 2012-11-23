class Article < ActiveRecord::Base
  attr_accessible :url, :title
  belongs_to :user

  def self.today
    where('created_at < ?', Time.now)
  end
end