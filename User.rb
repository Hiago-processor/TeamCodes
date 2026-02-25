# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :qr_codes, dependent: :destroy

  before_create :generate_api_token

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def generate_api_token!
    update!(api_token: generate_token)
  end

  private

  def generate_api_token
    self.api_token = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex(32)
      break token unless User.exists?(api_token: token)
    end
  end
end