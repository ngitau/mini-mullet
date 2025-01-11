class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true

  with_options if: -> { password.present? } do |with_password|
    with_password.validates :password, length: { minimum: 10, maximum: 16 }
    with_password.validates_with PasswordComplexityValidator
  end

  normalizes :name, with: ->(value) { value.strip }
end
