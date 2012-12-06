require 'sinatra/base'
require 'sinatra/activerecord'
require 'active_record'
require 'sinatra/sprockets'
require 'omniauth'
require 'omniauth-twitter'
require 'sinatra/flash'
require 'uri'
require 'awesome_print'

Dir['config/*.rb'].each {|file| require File.expand_path('../'+file, __FILE__) }
Dir['lib/*.rb'].each {|file| require File.expand_path('../'+file, __FILE__) }
Dir['models/*.rb'].each {|file| require File.expand_path('../'+file, __FILE__) }

class Application < Sinatra::Base
  register Sinatra::Flash
  register Sinatra::Sprockets
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']

  configure do
    enable :logging
    Time.zone = 'Eastern Time (US & Canada)'
  end

  # Database
  set :database, ENV['DATABASE_URL'] || 'postgres://localhost/hyperbole'
  ActiveRecord::Base.establish_connection('postgres://localhost/hyperbole')

  # Readability
  readability = Readability.new(ENV['READABILITY_KEY'])

  # Routes
  PROTECTED_ROUTES = ['logout', 'account/destroy', 'last-year', 'last-month', 'last-week', 'yesterday', 'today', 'add/']
  # Find a way to handle routes matching 'add/something'

  before '/*' do |route|
    if signed_in?
      Time.zone = @current_user.time_zone if @current_user.time_zone
    end

    if PROTECTED_ROUTES.include?(route) && signed_out?
      flash[:error] = "You need to be logged in to do that."
      redirect to('/')
    end
  end

  ['/last-year', '/last-month', '/last-week', '/today'].each do |route|
    after route do
      if @articles.empty?
        flash[:info] = "You haven't added any articles yet!"
        ap "You haven't added any articles yet!"
      end
    end
  end # doesn't work :(

  get '/' do
    if signed_in?
      @articles = @current_user.articles.group_by{ |d| d.created_at.beginning_of_day }
      erb :index
    else
      erb :frontpage
    end
  end # GET /

  get '/last-year' do
    @articles = @current_user.articles.previous_year.group_by{ |d| d.created_at.beginning_of_day }
    erb :index
  end # GET /last-year

  get '/last-month' do
    @articles = @current_user.articles.previous_month.group_by{ |d| d.created_at.beginning_of_day }
    erb :index
  end # GET /last-month

  get '/last-week' do
    @articles = @current_user.articles.previous_week.group_by{ |d| d.created_at.beginning_of_day }
    erb :index
  end # GET /last-week

  # get '/yesterday' do
  #   @articles = @current_user.articles.yesterday
  #   erb :index
  # end # GET /yesterday

  get '/today' do
    @articles = @current_user.articles.today.group_by{ |d| d.created_at.beginning_of_day }
    erb :index
  end # GET /today

  get '/add/*' do
    if @current_user
      uri = request.fullpath.sub(%r(^\/add\/), '')

      # valid_uri? doesn't work like expected -> FIX IT
      if valid_uri?(uri) # First check to prevent from making a bad request to readability
        uri = cleanup_uri(uri)

        begin
          readability_hash = readability.parse(uri)
        rescue *Readability::READABILITY_API_ERRORS => e
          flash[:error] = "Something went wrong: " + e.message
          redirect to('/')
        end

      else
       flash[:error] = "Invalid URI."
       redirect to('/')
      end

      begin
        article = Article.new
        article.user = @current_user
        article.uri = readability_hash[:url]
        article.title = readability_hash[:title]
        article.save!
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
        redirect to('/')
      end

      flash[:success] = "Article added!"
      redirect to('/today')
    else
      flash[:error] = "You need to be logged in to do that."
      redirect to('/') # Find a way to handle this with a before filter
    end
  end # GET /add/*

  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']

    # Existing user & existing authentication
    if @auth = Authentication.find_by_provider_and_uid(auth[:provider], auth[:uid])
      user = User.find(@auth.user)

    # New user and new authentication || Existing user and new authentication
    else
      user = User.find_or_create_from_auth(auth, @current_user) # implicitly creates authentication
    end

    login user
    flash[:success] = "Logged in!"
    redirect to('/')
  end # GET /auth/:provider/callback

  get '/auth/failure' do
    flash[:error] = "Oops... Something went wrong."
    redirect to('/')
  end # GET /auth/failure

  get '/logout' do
    logout @current_user
    flash[:success] = "Logged out!"
    redirect to('/')
  end # GET /logout

  get '/account/destroy' do
    @current_user.destroy
    flash[:success] = "Your account has been destroyed forever, forever, ever, forever, ever?"
  end # GET /account/destroy

  not_found do
    erb :error_404
  end

  # Helpers
  helpers do
    def login(user)
      session[:user_id] = user.id
      @current_user = user
    end

    def logout(user)
      @current_user = session[:user_id] = nil
    end

    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def signed_in?
      !!current_user
    end

    def signed_out?
      !current_user
    end

    def valid_uri?(uri)
      !(uri =~ URI::regexp).nil?
    end

    def cleanup_uri(uri)
      # Fix weird single slash uris given by request.fullpath
      uri = URI.split(uri)
      uri[5].sub!(%r(^\/{1}), '') if uri[2].nil?
      uri[0] << '://'
      uri.join
    end

    def greetings
      greetings ||= Greeter.new
      greetings.at(Time.zone.now)
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end