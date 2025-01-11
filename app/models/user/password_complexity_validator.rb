# frozen_string_literal: true

class User::PasswordComplexityValidator < ActiveModel::Validator
  attr_reader :password

  def validate(record)
    @password = record.password

    validate_has_digit(record)
    validate_has_lowercase_char(record)
    validate_has_uppercase_char(record)
    validate_has_three_repeating_char(record)
  end

  private

  def validate_has_digit(record)
    return if password =~ /\d/

    record.errors.add(:password, I18n.t("activerecord.errors.models.user.attributes.password.must_have_digit"))
  end

  def validate_has_lowercase_char(record)
    return if password =~ /[a-z]/

    record.errors.add(:password, I18n.t("activerecord.errors.models.user.attributes.password.must_have_lowercase_char"))
  end

  def validate_has_uppercase_char(record)
    return if password =~ /[A-Z]/

    record.errors.add(:password, I18n.t("activerecord.errors.models.user.attributes.password.must_have_uppercase_char"))
  end

  def validate_has_three_repeating_char(record)
    if password =~ /(.)\1\1/
      record.errors.add(:password, I18n.t("activerecord.errors.models.user.attributes.password.must_not_have_3_repeating_chars"))
    end
  end
end
