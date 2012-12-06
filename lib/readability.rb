require 'httparty'
require 'json'

class Readability
  attr_accessor :readability_api_key

  @@readability_api_uri = 'https://www.readability.com/api/content/v1/parser'

  def initialize(api_key)
    @readability_api_key = api_key
  end

  def parse(uri)
    raise ConfigurationError if @readability_api_key.blank?

    response = HTTParty.get(crafted_uri(uri))
    status = response.code

    case
    when status == 200
      result = JSON.parse(response.body)
      result.symbolize_keys!
    when status == 400 # Bad Request
      raise APIBadRequestError
    when status == 401 # Authorization Required
      raise APIUnauthorizedRequestError
    when status == 403 # Forbidden
      raise APIForbiddenError
    when status == 404 # Not Found
      raise APIError
    when status == 500 # Internal Server Error
      raise APIInternalServerError
    else
      raise APIRequestFailedError, uri
    end
  end

  protected

  def crafted_uri(uri)
    "#{@@readability_api_uri}/?url=#{uri}&token=#{@readability_api_key}"
  end

  class ConfigurationError < StandardError
    def initialize(message = "Api key not set.")
      super
    end
  end # class ConfigurationError

  class APIInternalServerError < StandardError
    def initialize(message = "Readability Content API is down.")
      super
    end
  end # class APIInternalServerError

  class APIUnauthorizedRequestError < StandardError
    def initialize(message = "Unauthorized request performed. Check your credentials")
      super
    end
  end # class APIUnauthorizedRequestError

  class APIBadRequestError < StandardError
    def initialize(message = "Bad request performed.")
      super
    end
  end # class APIBadRequestError

  class APIRequestFailedError < StandardError
    def initialize(uri)
      message = "Request failed: #{uri}"
      super(message)
    end
  end # class APIRequestFailedError

  READABILITY_API_ERRORS = [APIInternalServerError, APIUnauthorizedRequestError, APIBadRequestError, APIRequestFailedError]

end # class Readability
