Article.create(:uri => 'http://rmartinho.github.com/cxx11/2012/08/15/rule-of-zero.html', :title => 'Rule of Zero')
Article.create(:uri => 'http://www.kalzumeus.com/2011/10/28/', :title => 'Don\'t Call Yourself A Programmer, And Other Career Advice')
Article.create(:uri => 'http://steveblank.com/2012/11/23/careers-start-by-peeling-potatoes/', :title => 'Careers Start by Peeling Potatoes')
Article.create(:uri => 'https://www.google.com/takeaction/#', :title => 'Google\'s campaign for a free and open internet')

Article.find(1).update_attribute(:created_at, 300.day.ago.at_beginning_of_day)
Article.find(2).update_attribute(:created_at, 20.day.ago.at_beginning_of_day)
Article.find(3).update_attribute(:created_at, 5.day.ago.at_beginning_of_day)
Article.find(4).update_attribute(:created_at, 1.hour.ago.at_beginning_of_day)