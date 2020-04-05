#!/usr/bin/env ruby

require 'pp' # TODO drop
require 'cli'

require_relative 'lib/api/parallel_breeds_api'
require_relative 'lib/breeds_storage'

# FIXME not really sexy
def sanitize_input(opts)
  opts.breeds.map do |breed_name|
    breed_name.tr(',', '')
    # TODO URL sanitation
  end.uniq.reject!(&:empty?)
end

opts = CLI.new do
  description 'Fetches dog breed image links from dog API. See Readme.md for more.'
  version '0.0.1'
  arguments :breeds, description: 'Comma separated list of breeds. Sub-breeds follow separated by a dash, eg. bulldog-boston'
end.parse!

breed_names = sanitize_input(opts)

api = ParallelBreedsApi.new
breeds_from_api = api.fetch_breeds(breed_names)

BreedsStorage.save(breeds_from_api)