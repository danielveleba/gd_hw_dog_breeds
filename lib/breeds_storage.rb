# frozen_string_literal: true

require 'csv'
require 'oj'

# Persistence for the data fetched from the API
# Stores data in CSV files plus timestamps in a separate JSON
# All output is stored in a timestamped directory to minimize chances
# of overwriting existing files
class BreedsStorage
  OUT_DIR = "out-#{Time.now.strftime('%F_%H-%M-%S-%L')}"
  JSON_LOG_FILE = "#{OUT_DIR}/updated_at.json"
  HEADER = %w[breed link].freeze

  def self.save(breeds)
    Dir.mkdir(OUT_DIR)

    times = {}
    breeds.each do |breed, data|
      fname = save_to_csv(breed, data)
      fname = File.basename(fname)
      times[fname] = Time.now.utc
    end

    json = Oj.dump(times, mode: :json)
    log_time(json)
  end

  # rubocop:disable Metrics/MethodLength
  def self.save_to_csv(breed, data)
    breed = sanitize_input(breed)

    fname = "#{OUT_DIR}/#{breed}.csv"
    if File.exist?(fname)
      Main.logger.warn "File #{fname} already exists, will be overwritten"
    end

    CSV.open(fname, 'w') do |csv|
      csv << HEADER
      data.each do |line|
        csv << [breed, line]
      end
    end
    fname
  end
  # rubocop:enable Metrics/MethodLength

  def self.log_time(json)
    if File.exist?(JSON_LOG_FILE)
      Main.logger.warn "File #{JSON_LOG_FILE} exists, will be overwritten"
    end

    File.open(JSON_LOG_FILE, 'w') do |f|
      f.write(json)
    end
  end

  def self.sanitize_input(breed)
    breed.tr('/', '-')
  end

  private_class_method :sanitize_input, :log_time, :save_to_csv
end
