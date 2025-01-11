class Upload::CsvValidator < ActiveModel::Validator
  attr_reader :csv

  def validate(record)
    @csv = record.csv

    validate_rows_present?(record)
  end

  private

  def validate_rows_present?(record)
    return if csv.count > 0

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_have_data_rows"))
  end
end
