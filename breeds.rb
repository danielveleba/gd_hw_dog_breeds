#!/usr/bin/env ruby
# frozen_string_literal: true

require 'logger'
require 'cli'

require_relative 'lib/api/parallel_breeds_api'
require_relative 'lib/breeds_storage'

# Main entrypoint
# Also wraps logger and script return value for a use deeper down the road
class Main
  def self.logger
    init_logger unless @logger
    @logger
  end

  def self.ret
    @@ret
  end

  def self.ret=(val)
    @@ret = val # rubocop:disable Style/ClassVars
  end

  def self.run(breed_names)
    breed_names = sanitize_input(breed_names)

    api = ParallelBreedsApi.new(5, 60)
    breeds_from_api = api.fetch_breeds(breed_names)

    BreedsStorage.save(breeds_from_api)
  end

  def self.sanitize_input(breed_names)
    breed_names.map do |breed_name|
      breed_name.tr(',./ ', '')
    end.uniq.reject(&:empty?)
  end

  def self.init_logger
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  private_class_method :sanitize_input, :init_logger
end

opts = CLI.new do
  description 'Fetches dog breed image links from dog API. See Readme for more.'
  version '0.0.1'
  arguments :breeds, description:
      'Comma separated list of breeds. Sub-breeds follow separated by a dash, eg. bulldog-boston'
end.parse!

# noinspection RubyResolve
Main.run(opts.breeds)

exit(Main.ret)