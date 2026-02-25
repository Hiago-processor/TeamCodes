# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth
      scope :auth do
        post   'register', to: 'auth#register'
        post   'login',    to: 'auth#login'
        delete 'logout',   to: 'auth#logout'
        get    'me',       to: 'auth#me'
      end

      # QR Codes
      resources :qr_codes, only: [:index, :show, :create, :destroy] do
        member do
          post :regenerate
        end
        collection do
          get :generate  # Gera sem salvar
        end
      end
    end
  end

  # Rota pública para QR codes públicos
  get 'public/qr/:token', to: 'api/v1/qr_codes#show_public', as: :public_qr_code

  # Health check
  get 'health', to: proc { [200, {}, [{ status: 'ok', time: Time.current }.to_json]] }
end