require 'uri'
require 'readability'
require 'yaml'
Bundler.require(:default, :development, :assets)

Dir['lib/*.rb'].each {|file| require File.expand_path('../'+file, __FILE__) } # FIXME: Move assets into vendor/ directory
Dir['models/*.rb'].each {|file| require File.expand_path('../'+file, __FILE__) }


class Application < Sinatra::Base
  register Sinatra::Sprockets
  register Sinatra::Flash

  use Rack::Session::Cookie
  use OmniAuth::Strategies::Twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET']

  configure do
    set :app_name, 'Hyperbole'
    set :default_time_zone, 'Eastern Time (US & Canada)'

    enable :logging

    # Database
    database_config = ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[settings.environment.to_s]
    ActiveRecord::Base.establish_connection(database_config)

    # Sprockets
    Sinatra::Sprockets.configure do |config|
      config.digest = true              # Append a digest to URLs
      config.compile = true             # On-the-fly compilation
      config.manifest_path = 'assets'
      config.css_compressor = true     # CSS compressor instance
      config.js_compressor = true      # JS compressor instance
    end
  end

  # Readability
  Readability.api_token = ENV['READABILITY_API_KEY']


  # Routes
  PROTECTED_ROUTES = ['logout', 'account/destroy', 'last-year', 'last-month', 'last-week', 'today', 'add/'] # FIXME: Find a way to handle routes matching 'add/something'

  before '/*' do |route|
    if signed_in?
      login(@current_user)
      Time.zone = @current_user.time_zone if @current_user.time_zone

    elsif PROTECTED_ROUTES.include?(route)
      flash[:error] = "You need to be logged in to do that."
      redirect to('/')
    else
      Time.zone = settings.default_time_zone
    end
  end


  get '/' do
    if signed_in?
      @articles = @current_user.articles.group_by{ |d| d.created_at.beginning_of_day }
      erb :index
    else
      @articles = Article.previous_year.limit(20).group_by{ |d| d.created_at.beginning_of_day }
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


  get '/today' do
    @articles = @current_user.articles.today.group_by{ |d| d.created_at.beginning_of_day }
    erb :index
  end # GET /today


  get '/add/*' do
    if @current_user
      uri = request.fullpath.sub(%r(^\/add\/), '')

      # FIXME: valid_uri? doesn't work like expected
      if valid_uri?(uri) # First check to prevent from making a bad request to readability
        uri = sanitize_uri(uri)

        content = Readability.parse(uri)

      else
       flash[:error] = "Invalid URI."
       redirect to('/')
      end

      begin
        article = Article.new
        article.user = @current_user
        article.uri = content.url
        article.title = content.title
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
    redirect to('/')
  end # GET /auth/:provider/callback


  get '/auth/failure' do
    flash[:error] = "Oops... Something went wrong."
    redirect to('/')
  end # GET /auth/failure


  get '/logout' do
    logout @current_user
    flash[:success] = "Goodbye!"
    redirect to('/')
  end # GET /logout


  get '/account/destroy' do
    @current_user.destroy
    flash[:success] = "Your account has been destroyed forever, forever, ever, forever, ever?"
  end # GET /account/destroy


  not_found do
    erb :error_404
  end

  # FIXME: Doesn't work at all...
  after '/*' do |route|
    if ['last-year', 'last-month', 'last-week', 'today'].include?(route) && signed_in? && @articles.blank?
      flash[:info] = "You haven't added any articles yet!"
    end
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

    def valid_uri?(string)
      uri = URI.parse(string)
      return false if !['http', 'https'].include?(uri.scheme)
      return false if uri.host.blank? && uri.path.blank?
      true
    end

    def sanitize_uri(string)
      # Fix weird single slash uris given by request.fullpath
      uri = URI.split(string)
      uri[5].sub!(%r(^\/{1}), '') if uri[2].nil?
      uri[0] << '://'
      uri.join
    end

    def greetings
      greeter ||= Greeter.new
      greeter.at(Time.zone.now)
    end

    def friendly_date(time)
      date = time.today? ? "Today" : time.strftime('%B %d')
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end