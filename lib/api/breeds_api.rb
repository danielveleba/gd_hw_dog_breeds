# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

# Wrapper around the Dog breeds API
# Implemented as an instantiated object so that it can be held in a pool
class BreedsApi
  DOG_API_ROOT = 'https://dog.ceo/api/'
  DOG_API_PATH = 'breed/%s/images'

  def initialize
    @faraday = init_http_client
  end

  def fetch_breed(breed)
    @faraday.get(DOG_API_PATH % breed)
  end

  protected

  def init_http_client
    Faraday.new(url: DOG_API_ROOT,
                headers: { 'Content-Type' => 'application/json' }) do |f|

      f.response :json, content_type: /\bjson$/
    end
  end
end
