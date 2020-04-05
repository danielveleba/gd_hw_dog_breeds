# frozen_string_literal: true

require_relative 'api/parallel_breeds_api'
require_relative 'breeds_storage'

# Main entrypoint
# Also wraps logger and script return value for a use deeper down the road
class Main
  def self.logger
    init_logger unless @logger
    @logger
  end

  def self.ret
    @ret ||= 0
  end

  def self.ret=(val)
    @ret = val
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
