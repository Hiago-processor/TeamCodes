# app/controllers/api/v1/qr_codes_controller.rb
module Api
  module V1
    class QrCodesController < ApplicationController
      before_action :authenticate_user!, except: [:show_public]
      before_action :set_qr_code, only: [:show, :destroy, :regenerate]

      # GET /api/v1/qr_codes
      def index
        @qr_codes = current_user.qr_codes.order(created_at: :desc)
        render json: @qr_codes, each_serializer: QrCodeSerializer
      end

      # GET /api/v1/qr_codes/:id
      def show
        render json: @qr_code, serializer: QrCodeSerializer, include_image: true
      end

      # POST /api/v1/qr_codes
      def create
        @qr_code = current_user.qr_codes.build(qr_code_params)

        if @qr_code.save
          render json: @qr_code, serializer: QrCodeSerializer, include_image: true, status: :created
        else
          render json: { errors: @qr_code.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/qr_codes/:id
      def destroy
        @qr_code.destroy
        render json: { message: 'QR Code deletado com sucesso' }, status: :ok
      end

      # POST /api/v1/qr_codes/:id/regenerate
      def regenerate
        if @qr_code.regenerate!
          render json: @qr_code, serializer: QrCodeSerializer, include_image: true
        else
          render json: { errors: @qr_code.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/qr_codes/generate (inline, sem salvar)
      def generate
        result = QrCodeGeneratorService.new(
          content: params[:content],
          format: params[:format] || 'svg',
          size: params[:size]&.to_i || 4,
          color: params[:color] || '000000',
          background: params[:background] || 'ffffff'
        ).call

        if result[:success]
          respond_to do |format|
            format.json { render json: { qr_code: result[:data], format: result[:format] } }
            format.svg  { send_data result[:data], type: 'image/svg+xml', disposition: 'inline' }
            format.png  { send_data result[:data], type: 'image/png', disposition: 'inline' }
          end
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      # GET /public/qr/:token
      def show_public
        @qr_code = QrCode.find_by!(public_token: params[:token])
        @qr_code.increment!(:scan_count)

        render json: {
          id: @qr_code.id,
          content: @qr_code.content,
          label: @qr_code.label,
          scan_count: @qr_code.scan_count
        }
      end

      private

      def set_qr_code
        @qr_code = current_user.qr_codes.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'QR Code não encontrado' }, status: :not_found
      end

      def qr_code_params
        params.require(:qr_code).permit(
          :content, :label, :format, :size, :color, :background,
          :error_correction, :is_public
        )
      end
    end
  end
end