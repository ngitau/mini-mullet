require "csv"

class Upload
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true

  def csv
    @csv ||= begin
               CSV.parse(file&.read || "", headers: true)
             rescue CSV::MalformedCSVError
               errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file"))
               false
             end
  end
end
