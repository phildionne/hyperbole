class Article < ActiveRecord::Base
  attr_accessible :uri, :title

  validates_presence_of :uri, :user
  validates_format_of :uri, :with => URI::regexp

  belongs_to :user

  before_create           :cleanup_uri

  default_scope           order('DATE(created_at) DESC')

  scope :previous_year,   lambda { where('DATE(created_at) >= ?', 1.year.ago ) }
  scope :previous_month,  lambda { where('DATE(created_at) >= ?', 1.month.ago ) }
  scope :previous_week,   lambda { where('DATE(created_at) >= ?', 1.week.ago ) }
  # scope :yesterday,       lambda { where('DATE(created_at) = ?', 1.day.ago..Time.now.at_beginning_of_day)} # FIX this
  scope :today,           lambda { where('DATE(created_at) >= ?', Time.zone.now.at_beginning_of_day) }

  # scope :group_by_day,    group(['DATE(created_at)'])

  def date
    self.created_at.in_time_zone
  end

  protected

  def cleanup_uri
    uri = URI.split(self.uri)
    uri[5].sub!(%r(^\/{1}), '') if uri[2].nil?
    uri[0] << '://'
    self.uri = uri.join
  end
end