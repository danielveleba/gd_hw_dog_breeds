#!/usr/bin/env ruby
# frozen_string_literal: true

require 'logger'
require 'cli'

require_relative 'lib/main'

opts = CLI.new do
  description 'Fetches dog breed image links from dog API. See Readme for more.'
  version '0.0.1'
  arguments :breeds, description:
      'List of breeds. Sub-breeds are separated by a dash, eg. bulldog-boston'
end.parse!

# noinspection RubyResolve
Main.run(opts.breeds)

exit(Main.ret)