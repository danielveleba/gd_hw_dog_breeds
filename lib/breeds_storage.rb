require 'csv'
require 'oj'

class BreedsStorage
  OUT_DIR = "out-#{Time.now.strftime('%F_%H-%M-%S-%L')}".freeze
  JSON_LOG_FILE = "#{OUT_DIR}/updated_at.json".freeze
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

  protected

  def self.save_to_csv(breed, data)
    breed = sanitize_input(breed)

    fname = "#{OUT_DIR}/#{breed}.csv"
    if File.exist?(fname)
      $logger.warn "File #{fname} already exists, will be overwritten"
    end

    CSV.open(fname, 'w') do |csv|
      csv << HEADER
      data.each do |line|
        csv << [breed, line]
      end
    end
    fname
  end

  protected

  def self.log_time(json)
    if File.exist?(JSON_LOG_FILE)
      $logger.warn "File #{JSON_LOG_FILE} already exists, will be overwritten"
    end

    File.open(JSON_LOG_FILE, 'w') do |f|
      f.write(json)
    end
  end

  protected

  def self.sanitize_input(breed)
    breed.tr('/', '-')
  end
end