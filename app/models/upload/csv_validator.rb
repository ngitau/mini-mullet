class Upload::CsvValidator < ActiveModel::Validator
  attr_reader :file, :csv

  def validate(record)
    @file = record.file
    @csv = record.csv

    validate_rows_present(record)

    if file.present?
      validate_size(record)
    end

    validate_headers_present(record)
  end

  private

  def validate_rows_present(record)
    return if csv.count > 0

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_have_data_rows"))
  end

  def validate_size(record)
    return if file && File.size(file.path) < 10*(1024**2)

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_be_within_size_limit"))
  end

  def validate_headers_present(record)
    headers = %w[name password]
    return if (csv.headers & headers) == headers

    record.errors.add(:file, I18n.t("activemodel.errors.models.upload.attributes.file.must_have_required_headers"))
  end
end
