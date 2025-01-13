require "csv"

class Upload
  include ActiveModel::Model

  attr_reader :file
  attr_accessor :results, :batch_size

  validates :file, presence: true
  validates_with CsvValidator, if: :csv

  def initialize(attributes = {})
    @file = attributes[:file]
    @batch_size = attributes[:batch_size] || 100
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
             rescue CSV::MalformedCSVError
               CSV.parse(normalized_str, headers: true)
               handle_malformed_csv_error
             end
  end

  def update_file
    return if normalized_str.equal?(contents)

    File.open(file.path, "w") do |file|
      file.write(normalized_str)
    end
  end


  def process_whole
    csv.each_with_object(results) do |csv_row, outcomes|
      row = csv_row.to_h

      user = User.create(row.slice("name", "password"))
      row["valid?"] = user.valid?
      row["result"] = user.valid? ? "Success" : user.errors.full_messages.join(", ")

      outcomes << (row)
    end
  end

  def process_in_batches
    return false unless valid?

    batch = []

    CSV.foreach(file, headers: true) do |row|
      batch << row.to_h

      if batch.size >= batch_size
        results = process_batch(batch)
        batch.clear
      end
    end

    process_batch(batch) if batch.any?
    true
  end

  private

  def process_batch(batch) = User.create_from_collection(batch, results)

  def handle_malformed_csv_error
    errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file"))
    false
  end
end
