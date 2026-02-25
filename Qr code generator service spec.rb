# spec/services/qr_code_generator_service_spec.rb
require 'rails_helper'

RSpec.describe QrCodeGeneratorService do
  describe '#call' do
    subject(:service) { described_class.new(options).call }

    context 'com SVG (padrão)' do
      let(:options) { { content: 'https://example.com' } }

      it 'retorna sucesso' do
        expect(service[:success]).to be true
      end

      it 'retorna SVG válido' do
        expect(service[:data]).to include('<svg')
      end

      it 'retorna formato correto' do
        expect(service[:format]).to eq('svg')
      end
    end

    context 'com PNG' do
      let(:options) { { content: 'Hello World', format: 'png' } }

      it 'retorna sucesso' do
        expect(service[:success]).to be true
      end

      it 'retorna dados binários PNG' do
        expect(service[:data]).to start_with("\x89PNG")
      end
    end

    context 'com base64_svg' do
      let(:options) { { content: 'test', format: 'base64_svg' } }

      it 'retorna string base64' do
        expect(service[:data]).to match(/\A[A-Za-z0-9+\/=]+\z/)
      end
    end

    context 'com conteúdo vazio' do
      let(:options) { { content: '' } }

      it 'retorna erro' do
        expect(service[:success]).to be false
        expect(service[:error]).to include('vazio')
      end
    end

    context 'com formato inválido' do
      let(:options) { { content: 'test', format: 'gif' } }

      it 'retorna erro' do
        expect(service[:success]).to be false
      end
    end

    context 'com cor inválida' do
      let(:options) { { content: 'test', color: 'not-a-color' } }

      it 'retorna erro' do
        expect(service[:success]).to be false
      end
    end

    context 'com URL longa' do
      let(:options) { { content: 'https://example.com/very/long/path?param=value&other=123' } }

      it 'gera QR code corretamente' do
        expect(service[:success]).to be true
      end
    end
  end
end