require 'rails_helper'

RSpec.describe 'Currencies', type: :request do
  describe 'POST /currencies/:id/convert' do
    let(:currency_id) { 1 }
    let(:valid_params) do
      {
        from_currency: 'USD',
        to_currency: 'EUR',
        amount: 100.0
      }
    end

    context 'with valid parameters' do
      it 'returns a successful response' do
        post "/currencies/#{currency_id}/convert", params: valid_params
        
        expect(response).to have_http_status(:no_content)
      end

      it 'accepts the required parameters' do
        post "/currencies/#{currency_id}/convert", params: valid_params
        
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with missing parameters' do
      it 'handles missing from_currency' do
        params = valid_params.except(:from_currency)
        post "/currencies/#{currency_id}/convert", params: params
        
        expect(response).to have_http_status(:no_content)
      end

      it 'handles missing to_currency' do
        params = valid_params.except(:to_currency)
        post "/currencies/#{currency_id}/convert", params: params
        
        expect(response).to have_http_status(:no_content)
      end

      it 'handles missing amount' do
        params = valid_params.except(:amount)
        post "/currencies/#{currency_id}/convert", params: params
        
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid parameters' do
      it 'handles empty parameters' do
        post "/currencies/#{currency_id}/convert", params: {}
        
        expect(response).to have_http_status(:no_content)
      end

      it 'handles non-numeric amount' do
        params = valid_params.merge(amount: 'invalid')
        post "/currencies/#{currency_id}/convert", params: params
        
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
