# app/models/qr_code.rb
class QrCode < ApplicationRecord
  belongs_to :user

  before_create :generate_public_token
  after_create  :generate_image_data

  # Validações
  validates :content, presence: true, length: { maximum: 4296 }
  validates :label,   length: { maximum: 100 }
  validates :format,  inclusion: { in: %w[svg png base64_svg base64_png] }
  validates :size,    numericality: { greater_than: 0, less_than_or_equal_to: 40 }
  validates :color,      format: { with: /\A[0-9a-fA-F]{6}\z/, message: 'deve ser hex sem #' }
  validates :background, format: { with: /\A[0-9a-fA-F]{6}\z/, message: 'deve ser hex sem #' }
  validates :error_correction, inclusion: { in: %w[l m q h] }

  # Defaults
  attribute :format,           :string,  default: 'svg'
  attribute :size,             :integer, default: 4
  attribute :color,            :string,  default: '000000'
  attribute :background,       :string,  default: 'ffffff'
  attribute :error_correction, :string,  default: 'm'
  attribute :scan_count,       :integer, default: 0
  attribute :is_public,        :boolean, default: false

  scope :public_qrcodes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }

  def regenerate!
    result = generate_qr_data
    if result[:success]
      update(image_data: result[:data])
    else
      errors.add(:base, result[:error])
      false
    end
  end

  def public_url
    return nil unless is_public?
    "/public/qr/#{public_token}"
  end

  private

  def generate_public_token
    self.public_token = SecureRandom.urlsafe_base64(16)
  end

  def generate_image_data
    result = generate_qr_data
    update_column(:image_data, result[:data]) if result[:success]
  end

  def generate_qr_data
    QrCodeGeneratorService.new(
      content:          content,
      format:           format,
      size:             size,
      color:            color,
      background:       background,
      error_correction: error_correction
    ).call
  end
end