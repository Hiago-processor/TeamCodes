# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      # POST /api/v1/auth/register
      def register
        @user = User.new(user_params)

        if @user.save
          render json: {
            message: 'Usuário criado com sucesso',
            user: user_response(@user),
            api_token: @user.api_token
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        @user = User.find_by(email: params[:email]&.downcase)

        if @user&.authenticate(params[:password])
          @user.generate_api_token! # Rotaciona o token a cada login
          render json: {
            message: 'Login realizado com sucesso',
            user: user_response(@user),
            api_token: @user.api_token
          }
        else
          render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        authenticate_user!
        return if performed?

        current_user.generate_api_token! # Invalida o token atual
        render json: { message: 'Logout realizado com sucesso' }
      end

      # GET /api/v1/auth/me
      def me
        authenticate_user!
        return if performed?

        render json: user_response(current_user)
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def user_response(user)
        {
          id:         user.id,
          name:       user.name,
          email:      user.email,
          qr_count:   user.qr_codes.count,
          created_at: user.created_at
        }
      end
    end
  end
end