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

  def process_in_batches(batch_size = 100)
  rescue CSV::MalformedCSVError
    handle_malformed_csv_error
  end

  def handle_malformed_csv_error
    errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file"))
    false
  end
end
