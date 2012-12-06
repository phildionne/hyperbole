require './app'

# http://stackoverflow.com/questions/10191531/activerecord-connection-warning-database-connections-will-not-be-closed-automa
use ActiveRecord::ConnectionAdapters::ConnectionManagement

map "/#{Sinatra::Sprockets.config.prefix}" do
  run Sinatra::Sprockets.environment
end

run Application