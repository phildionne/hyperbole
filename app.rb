require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/activerecord'
require 'active_record'
require 'sinatra/flash'
require 'uri'

Dir["models/*.rb"].each {|file| require File.expand_path('../'+file, __FILE__) }

class Application < Sinatra::Base
  enable :sessions
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack
  register Sinatra::Flash

  # Database
  set :database, ENV['DATABASE_URL'] || 'postgres://localhost/hyperbole'
  ActiveRecord::Base.establish_connection('postgres://localhost/hyperbole')

  # ASSET BUG
  # Looks like assetpack can't find less because it's managed under rbenv
  #

  # Assets
  assets {
    serve '/js',      from: 'assets/js'
    serve '/css',     from: 'assets/css'
    serve '/img',     from: 'assets/img'

    js :app, [
      '/js/app.js'
    ]

    css :app, [
      '/css/app.css',
      '/css/vendor/bootstrap/bootstrap.css',
      '/css/vendor/bootstrap/responsive.css'
    ]
  }

  # Routes
  # GET /
  get '/' do
    @articles = Article.find(:all, :order => 'created_at DESC')

    erb :index
  end

  # GET /today
  get '/today' do
    @articles = Article.today
    erb :index
  end

  # GET /add/:url
  get '/add/*' do |url|

    if url =~ URI::regexp
      article = Article.new
      article.url = url
      article.save

      redirect to('/')
    else
      flash[:error] = "Invalid url"
      redirect to('/')
    end
  end

  not_found do
    erb :error_404
  end

  get '/db/seed' do
    Article.create(:url => 'http://rmartinho.github.com/cxx11/2012/08/15/rule-of-zero.html', :title => 'Rule of Zero')
    Article.create(:url => 'http://www.kalzumeus.com/2011/10/28/', :title => 'Don\'t Call Yourself A Programmer, And Other Career Advice')
    Article.create(:url => 'http://steveblank.com/2012/11/23/careers-start-by-peeling-potatoes/', :title => 'Careers Start by Peeling Potatoes')
    Article.create(:url => 'https://www.google.com/takeaction/#', :title => 'Google\'s campaign for a free and open internet')
    Article.create(:url => 'http://lists.gnu.org/archive/html/gnu-system-discuss/2012-11/msg00000.html', :title => 'Introducing GNU Guix')
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end