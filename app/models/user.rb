class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true

  with_options if: -> { password.present? } do |with_password|
    with_password.validates :password, length: { minimum: 10, maximum: 16 }
    with_password.validates_with PasswordComplexityValidator
  end

  normalizes :name, with: ->(value) { value.strip }

  class << self
    def create_from_collection(rows, results)
      rows.each_with_object(results) do |row, outcomes|
        user = User.create(row.slice("name", "password"))
        row["valid?"] = user.valid?
        row["result"] = user.valid? ? "Success" : user.errors.full_messages.join(", ")

        outcomes << (row)
      end
    end
  end
end
