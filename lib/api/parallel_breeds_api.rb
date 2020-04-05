# frozen_string_literal: true

require 'logger'
require 'connection_pool'
require 'thread/pool'

require_relative 'breeds_api'

# Provides parallel calling of the BreedsApi
# Aside from thread pool sets also connection pool to allow for HTTP connection reusing
class ParallelBreedsApi
  # @param timeout How long to wait to get a thread from the pool
  def initialize(num_threads = 5, timeout = 60)
    @conn_pool = ConnectionPool.new(size: num_threads, timeout: timeout) { BreedsApi.new }
    @thread_pool = Thread.pool(num_threads)
  end

  # rubocop:disable Metrics/MethodLength
  def fetch_breeds(breed_names)
    breed_names = sanitize_input(breed_names)

    # nb: the map won't suffice if there are duplicate breeds;
    # thus the `uniq` in input sanitation
    res = {}
    breed_names.each do |breed_name|
      tmp = @thread_pool.process do
        @conn_pool.with do |breeds_api|
          breeds_api.call_breeds_api(breed_name)
        end
      end
      res[breed_name] = tmp
    end

    @thread_pool.wait(:done)

    process_results(res)
  end
  # rubocop:enable Metrics/MethodLength

  protected

  def sanitize_input(breed_names)
    breed_names.map do |breed|
      breed.tr!('-', '/')
    end
    breed_names.uniq
  end

  # rubocop:disable Metrics/MethodLength
  def process_results(results)
    res = {}

    results.each do |breed, task|
      if task.exception
        $logger.error "Fetching data for breed #{breed} raised exception: "\
        "#{task.exception}"
        $ret = -1
      else
        # if `task.result.status` raises an exception for any reason, it's a bug
        # in the script. thus not handled
        case task.result.status
        when 200
          res[breed] = task.result.body['message']
        else
          $logger.warn 'API returned non-200 status for breed'\
          " #{breed}: #{task.result.inspect}"
          $ret = -1
        end
      end
    end

    res
  end
  # rubocop:enable Metrics/MethodLength
end
