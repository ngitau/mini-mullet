require "csv"

class Upload
  include ActiveModel::Model

  attr_reader :file
  attr_accessor :results, :batch_size, :col_sep

  validates :file, presence: true
  validates_with CsvValidator, if: :csv

  def initialize(attributes = {})
    @file = attributes[:file]
    @batch_size = attributes[:batch_size] || 100
    @col_sep = attributes[:col_sep] || ","
    @results = []
  end

  def contents
    @contents ||= file&.read || ""
  end

  def normalized_str
    @normalized_str ||= begin
                          return contents unless contents.include?("\r")
                          contents.gsub("\r\r\n", "\n").gsub("\r", "\n")
                        end
  end

  def csv
    @csv ||= begin
               CSV.parse(normalized_str, headers: true, col_sep:)
             rescue CSV::MalformedCSVError, NoMethodError
               handle_malformed_csv_error
             end
  end

  def size
    @size ||= file.present? ? File.size(file.path) : 0
  end

  def update_file
    return if normalized_str.equal?(contents)

    File.open(file.path, "w") do |file|
      file.write(normalized_str)
    end
  end

  def save = self.valid? ? self.process && true : false

  def process
    # TODO:// return process_later if size > 1.megabyte

    return process_whole if csv.count < batch_size

    update_file
    process_in_batches
  end

  def process_later
    # TODO://
    #   - Upload file using ActiveStorage (ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)
    #   - UploadJob.perform_later(checksum: blob.checksum)
    #   - Notify user the job will be processed in the background
    #   - In the Job - call #process_and_stream_results
  end

  def process_whole
    @results = csv.map do |csv_row|
      row = csv_row.to_h
      next if row.values.all?(nil)

      user = User.create(row.slice("name", "password"))
      row["valid?"] = user.valid?
      row["result"] = user.valid? ? "Success" : user.errors.full_messages.join(", ")
      row
    end.compact
  end

  def process_in_batches
    return false unless valid?

    batch = []

    CSV.foreach(file, headers: true, col_sep:) do |row|
      batch << row.to_h

      if batch.size >= batch_size
        process_batch(batch)
        batch.clear
      end
    end

    process_batch(batch) if batch.any?
    true
  end

  private

  def process_batch(batch)
    results.concat User.create_from_collection(batch)
  end

  def handle_malformed_csv_error
    errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file"))
    false
  end
end
