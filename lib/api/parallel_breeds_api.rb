require 'logger'
require 'connection_pool'
require 'thread/pool'

require_relative 'breeds_api'

class ParallelBreedsApi
  def initialize(num_threads = 5, timeout = 60)
    # @conn_pool = ConnectionPool.new(size: num_threads, timeout: timeout) { BreedsApi.new } # FIXME
    @thread_pool = Thread.pool(num_threads)
  end

  def fetch_breeds(breed_names)
    breed_names = sanitize_input(breed_names)

    # nb: the map won't suffice if there are duplicate breeds;
    # thus the `uniq` in input sanitation
    res = {}
    breed_names.each do |breed_name|
      tmp = @thread_pool.process do
        # @conn_pool.with do |breeds_api|
        BreedsApi.new.call_breeds_api(breed_name)
        # end
      end
      res[breed_name] = tmp
    end

    @thread_pool.wait(:done)

    process_results(res)
  end

  protected

  def sanitize_input(breed_names)
    breed_names.map do |breed|
      breed.tr!('-', '/')
    end
    breed_names.uniq
  end

  def process_results(results)
    res = {}

    results.each do |breed, task|
      # if `task.result.status` raises an exception for any reason, it's a bug
      # in the script. thus not handled
      case task.result.status
      when 200
        res[breed] = task.result.body['message']
      else
        $logger.warn "API returned non-200 status for breed #{breed}: #{task.result.inspect}"
      end
    end

    res
  end
end