#!/usr/bin/env ruby
# frozen_string_literal: true

require 'logger'
require 'cli'

require_relative 'lib/api/parallel_breeds_api'
require_relative 'lib/breeds_storage'

$ret = 0

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

opts = CLI.new do
  description 'Fetches dog breed image links from dog API. See Readme for more.'
  version '0.0.1'
  arguments :breeds, description:
      'Comma separated list of breeds. Sub-breeds follow separated by a dash, eg. bulldog-boston'
end.parse!

# noinspection RubyResolve
breed_names = opts.breeds.map do |breed_name|
  breed_name.tr(',./ ', '')
end.uniq.reject!(&:empty?)

api = ParallelBreedsApi.new(5, 60)
breeds_from_api = api.fetch_breeds(breed_names)

BreedsStorage.save(breeds_from_api)

exit($ret)