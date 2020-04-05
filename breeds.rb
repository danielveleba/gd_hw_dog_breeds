#!/usr/bin/env ruby

require 'pp' # TODO drop
require 'cli'

require_relative 'lib/api/breeds_api'

def sanitize_input(opts)
  opts.breeds.map do |breed_name|
    breed_name.tr(',', '')
    # TODO URL sanitization
  end.uniq.reject!(&:empty?)
end

opts = CLI.new do
  description 'Fetches dog breed image links from dog API. See Readme.md for more.'
  version '0.0.1'
  arguments :breeds, description: 'Comma separated list of breeds. Sub-breeds follow separated by a dash, eg. bulldog-boston'
end.parse!

pp opts.breeds # TODO drop

breed_names = sanitize_input(opts)

pp breed_names # TODO drop

breeds_from_api = BreedsApi.fetch_breeds(breed_names)

pp breeds_from_api # TODO drop

# BreedsStorage.save(breeds_from_api)