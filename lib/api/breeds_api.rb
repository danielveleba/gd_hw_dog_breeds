require 'faraday'
require 'faraday_middleware'

class BreedsApi
  DOG_API_ROOT = 'https://dog.ceo/api/'
  DOG_API_PATH = 'breed/%{breed}/images'

  def initialize
    @faraday = init_http_client
  end

  def call_breeds_api(breed)
    res = @faraday.get(DOG_API_PATH % {breed: breed})
    pp res.body
  end

  protected

  def init_http_client
    Faraday.new(url: DOG_API_ROOT) do |f|
      f.request :json

      f.response :json, content_type: /\bjson$/
    end
  end
end
