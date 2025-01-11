require "csv"

class Upload
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true
  validates_with CsvValidator, if: :csv

  def csv
    @csv ||= begin
               CSV.parse(file&.read || "", headers: true)
             rescue CSV::MalformedCSVError
               handle_malformed_csv_error
             end
  end

  def results
    @results ||= []
  end

  def process_in_batches(batch_size = 100)
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
