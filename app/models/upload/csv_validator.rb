class Upload::CsvValidator < ActiveModel::Validator
  attr_reader :csv

  def validate(record)
    @csv = record.csv

    validate_rows_present(record)
    validate_headers_present(record)
  end

  private

  def validate_rows_present(record)
    return if csv.count > 0

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_have_data_rows"))
  end

  def validate_headers_present(record)
    headers = %w[name password]
    return if (csv.headers & headers) == headers

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_have_required_headers"))
  end
end
