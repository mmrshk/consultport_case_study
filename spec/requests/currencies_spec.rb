# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

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

    let(:mock_api_response) do
      {
        'result' => 'success',
        'provider' => 'https://www.exchangerate-api.com',
        'time_last_update_utc' => 'Mon, 15 Sep 2025 00:02:31 +0000',
        'time_next_update_utc' => 'Tue, 16 Sep 2025 00:11:41 +0000',
        'base_code' => 'USD',
        'rates' => {
          'USD' => 1,
          'EUR' => 0.852764,
          'GBP' => 0.73784
        }
      }
    end

    context 'when API is triggered' do
      before do
        stub_request(:get, 'https://open.er-api.com/v6/latest/USD')
          .to_return(
            status: 200,
            body: mock_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      context 'with valid parameters' do
        it 'returns a successful response with converted amount' do
          post "/currencies/#{currency_id}/convert", params: valid_params

          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response).to include('converted_amount')
          expect(json_response['converted_amount'].to_f).to eq(85.28) # 100 * 0.852764 rounded to 2 decimals
        end

        it 'creates a new exchange rate record' do
          expect do
            post "/currencies/#{currency_id}/convert", params: valid_params
          end.to change(ExchangeRate, :count).by(1)
        end

        it 'stores the correct exchange rate data' do
          post "/currencies/#{currency_id}/convert", params: valid_params

          exchange_rate = ExchangeRate.last
          expect(exchange_rate.from).to eq('USD')
          expect(exchange_rate.to).to eq('EUR')
          expect(exchange_rate.rate).to eq(0.852764)
          expect(exchange_rate.provider).to eq('ExchangeRate-API')
        end
      end

      xcontext 'with missing parameters' do
        it 'handles missing from_currency' do
          params = valid_params.except(:from_currency)
          post "/currencies/#{currency_id}/convert", params: params

          expect(response).to have_http_status(:unprocessable_entity)

          json_response = JSON.parse(response.body)
          expect(json_response).to include('message')
          expect(json_response['message']).to include('Missing required parameters')
        end

        it 'handles missing to_currency' do
          params = valid_params.except(:to_currency)
          post "/currencies/#{currency_id}/convert", params: params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'handles missing amount' do
          params = valid_params.except(:amount)
          post "/currencies/#{currency_id}/convert", params: params

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'with invalid parameters' do
        it 'handles empty parameters' do
          post "/currencies/#{currency_id}/convert", params: {}

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when API fails' do
        before do
          stub_request(:get, 'https://open.er-api.com/v6/latest/USD')
            .to_return(status: 500, body: 'Internal Server Error')
        end

        it 'handles API errors gracefully' do
          post "/currencies/#{currency_id}/convert", params: valid_params

          expect(response).to have_http_status(:unprocessable_entity)

          json_response = JSON.parse(response.body)
          expect(json_response).to include('message')
          expect(json_response['message']).to include('Failed to fetch or create exchange rate')
        end
      end
    end
  end
end
