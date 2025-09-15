require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ExchangeRateApiService do
  let(:service) { described_class.new }
  let(:from_currency) { 'USD' }
  let(:to_currency) { 'EUR' }

  describe '#fetch_rates' do
    context 'with successful API response' do
      let(:mock_response) do
        {
          'result' => 'success',
          'provider' => 'https://www.exchangerate-api.com',
          'time_last_update_utc' => 'Mon, 15 Sep 2025 00:02:31 +0000',
          'time_next_update_utc' => 'Tue, 16 Sep 2025 00:11:41 +0000',
          'base_code' => 'USD',
          'rates' => {
            'USD' => 1,
            'EUR' => 0.852764,
            'GBP' => 0.73784,
            'JPY' => 147.723052
          }
        }
      end

      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .with(
            headers: {
              'Accept' => 'application/json',
              'User-Agent' => 'Rails Currency Converter'
            }
          )
          .to_return(
            status: 200,
            body: mock_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed exchange rate data' do
        result = service.fetch_rates(from_currency, to_currency)

        expect(result).to include(
          from: 'USD',
          to: 'EUR',
          rate: 0.852764,
          provider: 'ExchangeRate-API',
          last_updated: 'Mon, 15 Sep 2025 00:02:31 +0000',
          next_update: 'Tue, 16 Sep 2025 00:11:41 +0000'
        )
      end

      it 'handles different currency pairs' do
        result = service.fetch_rates('USD', 'GBP')

        expect(result[:to]).to eq('GBP')
        expect(result[:rate]).to eq(0.73784)
      end

      it 'handles case insensitive currency codes' do
        result = service.fetch_rates('usd', 'eur')

        expect(result[:from]).to eq('USD')
        expect(result[:to]).to eq('EUR')
        expect(result[:rate]).to eq(0.852764)
      end
    end

    context 'with API error response' do
      let(:error_response) do
        {
          'result' => 'error',
          'error' => 'Invalid currency code'
        }
      end

      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(
            status: 200,
            body: error_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises an error for API errors' do
        expect {
          service.fetch_rates(from_currency, to_currency)
        }.to raise_error(StandardError, 'API returned error: Invalid currency code')
      end
    end

    context 'with currency pair not found' do
      let(:mock_response) do
        {
          'result' => 'success',
          'base_code' => 'USD',
          'rates' => {
            'USD' => 1,
            'EUR' => 0.852764
          }
        }
      end

      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(
            status: 200,
            body: mock_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises an error when currency pair is not found' do
        expect {
          service.fetch_rates(from_currency, 'INVALID')
        }.to raise_error(StandardError, 'Currency pair USD/INVALID not found')
      end
    end

    context 'with HTTP errors' do
      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an error for HTTP failures' do
        expect {
          service.fetch_rates(from_currency, to_currency)
        }.to raise_error(StandardError, 'API request failed with status: 500')
      end
    end

    context 'with network timeout' do
      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_timeout
      end

      it 'retries and eventually raises an error' do
        expect {
          service.fetch_rates(from_currency, to_currency)
        }.to raise_error(StandardError)
      end
    end

    context 'with retry logic' do
      let(:mock_response) do
        {
          'result' => 'success',
          'base_code' => 'USD',
          'rates' => { 'EUR' => 0.852764 }
        }
      end

      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(status: 500)
          .then
          .to_return(status: 500)
          .then
          .to_return(
            status: 200,
            body: mock_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'retries failed requests and succeeds eventually' do
        result = service.fetch_rates(from_currency, to_currency)

        expect(result[:rate]).to eq(0.852764)
      end
    end

    context 'with malformed JSON response' do
      before do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(
            status: 200,
            body: 'invalid json',
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises an error for malformed JSON' do
        expect {
          service.fetch_rates(from_currency, to_currency)
        }.to raise_error(JSON::ParserError)
      end
    end
  end
end
