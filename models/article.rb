class Article < ActiveRecord::Base
  attr_accessible :uri, :title

  belongs_to :user

  validates_presence_of :uri, :title, :user
  validates_format_of :uri, :with => URI::regexp

  default_scope           order('DATE(created_at) DESC')
  scope :previous_year,   lambda { where('DATE(created_at) >= ?', 1.year.ago ) }
  scope :previous_month,  lambda { where('DATE(created_at) >= ?', 1.month.ago ) }
  scope :previous_week,   lambda { where('DATE(created_at) >= ?', 1.week.ago ) }
  # scope :yesterday,       lambda { where('DATE(created_at) = ?', 1.day.ago..Time.now.at_beginning_of_day)} # FIX this
  scope :today,           lambda { where('DATE(created_at) >= ?', Time.zone.now.at_beginning_of_day) }

end