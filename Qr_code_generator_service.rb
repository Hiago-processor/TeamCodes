# app/services/qr_code_generator_service.rb
require 'rqrcode'
require 'base64'

class QrCodeGeneratorService
  VALID_FORMATS = %w[svg png base64_svg base64_png].freeze
  VALID_ERROR_CORRECTIONS = %w[l m q h].freeze
  MIN_SIZE = 1
  MAX_SIZE = 40

  def initialize(options = {})
    @content          = options[:content].to_s.strip
    @format           = options[:format]&.downcase || 'svg'
    @size             = options[:size]&.to_i || 4
    @color            = options[:color] || '000000'
    @background       = options[:background] || 'ffffff'
    @error_correction = options[:error_correction]&.to_sym || :m
  end

  def call
    validate!

    qr = RQRCode::QRCode.new(@content, level: @error_correction)

    data = case @format
           when 'svg'        then generate_svg(qr)
           when 'png'        then generate_png(qr)
           when 'base64_svg' then Base64.strict_encode64(generate_svg(qr))
           when 'base64_png' then Base64.strict_encode64(generate_png(qr))
           else generate_svg(qr)
           end

    { success: true, data: data, format: @format }

  rescue RQRCode::QRCodeRunTimeError => e
    { success: false, error: "Erro ao gerar QR Code: #{e.message}" }
  rescue ArgumentError => e
    { success: false, error: e.message }
  end

  private

  def validate!
    raise ArgumentError, 'Conteúdo não pode ser vazio' if @content.blank?
    raise ArgumentError, 'Conteúdo muito longo (máximo 4296 caracteres)' if @content.length > 4296
    raise ArgumentError, "Formato inválido. Use: #{VALID_FORMATS.join(', ')}" unless VALID_FORMATS.include?(@format)
    raise ArgumentError, "Tamanho deve ser entre #{MIN_SIZE} e #{MAX_SIZE}" unless @size.between?(MIN_SIZE, MAX_SIZE)
    raise ArgumentError, "Cor inválida (use hex sem #)" unless valid_hex?(@color)
    raise ArgumentError, "Cor de fundo inválida (use hex sem #)" unless valid_hex?(@background)
    raise ArgumentError, "Correção de erro inválida. Use: l, m, q, h" unless VALID_ERROR_CORRECTIONS.include?(@error_correction.to_s)
  end

  def generate_svg(qr)
    qr.as_svg(
      offset: 0,
      color: @color,
      shape_rendering: 'crispEdges',
      module_size: @size * 2,
      standalone: true,
      use_path: true
    )
  end

  def generate_png(qr)
    # Usando chunky_png via rqrcode
    png = qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: @size * 2,
      resize_exactly_to: false,
      resize_gte_to: false
    )
    png.to_blob
  end

  def valid_hex?(color)
    color.match?(/\A[0-9a-fA-F]{6}\z/)
  end
end