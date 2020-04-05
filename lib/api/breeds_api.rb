require 'faraday'
require 'faraday_middleware'

class BreedsApi
  DOG_API_ROOT = 'https://dog.ceo/api/'
  DOG_API_PATH = 'breed/%{breed}/images'

  def self.fetch_breeds(breed_names)
    @faraday = init_http_client

    breed_names.map do |breed|
      breed.tr!('-', '/')
    end

    call_breeds_api(breed_names)
  end

  protected

  def self.init_http_client
    Faraday.new(url: DOG_API_ROOT) do |f|
      f.request :json

      f.response :json, content_type: /\bjson$/
    end
  end

  def self.call_breeds_api(breeds)
    @faraday.get(DOG_API_PATH % {breed: breeds.first})
  end
end
