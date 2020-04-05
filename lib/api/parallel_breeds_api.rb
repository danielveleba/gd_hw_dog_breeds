require 'connection_pool'
require 'thread/pool'

require_relative 'breeds_api'

class ParallelBreedsApi
  def initialize(num_threads = 5, timeout = 60)
    # @conn_pool = ConnectionPool.new(size: num_threads, timeout: timeout) { BreedsApi.new } # FIXME
    @thread_pool = Thread.pool(num_threads)
  end

  def fetch_breeds(breed_names)
    breed_names.map do |breed|
      breed.tr!('-', '/')
    end

    res = []
    breed_names.each do |breed_name|
      res << @thread_pool.process do
        # @conn_pool.with do |breeds_api|
        BreedsApi.new.call_breeds_api(breed_name) # TODO handle failures
        # end
      end
    end

    @thread_pool.wait(:done)

    res
  end
end