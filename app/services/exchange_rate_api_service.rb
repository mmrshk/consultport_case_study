class ExchangeRateApiService
  BASE_URL = 'https://open.er-api.com/v6/latest'
  MAX_RETRY_COUNT = 3
  RETRY_DELAY = 1
  
  def fetch_rates(from_currency, to_currency)
    retries = 0

    begin
      response = call_exchange_rate_api(from_currency, to_currency)

      parse_response(response, from_currency, to_currency)
    rescue StandardError => e
      retries += 1

      if retries < MAX_RETRY_COUNT
        sleep(RETRY_DELAY)
        retry
      else
        handle_api_error(e)
      end
    end
  end

  private

  def call_exchange_rate_api(from_currency, to_currency)
    url = "#{BASE_URL}/#{from_currency.upcase}"
    
    response = HTTParty.get(url, {
      timeout: 10,
      headers: { 'Accept' => 'application/json' }
    })
    
    unless response.success?
      raise StandardError, "API request failed with status: #{response.code}"
    end
    
    response
  end

  def parse_response(response, from_currency, to_currency)
    data = JSON.parse(response.body)
    
    unless data['result'] == 'success'
      raise StandardError, "API returned error: #{data['error'] || 'Unknown error'}"
    end
    
    rate = data['rates'][to_currency.upcase]
    
    unless rate
      raise StandardError, "Currency pair #{from_currency}/#{to_currency} not found"
    end
    
    {
      from: from_currency.upcase,
      to: to_currency.upcase,
      rate: rate.to_f,
      provider: 'ExchangeRate-API',
    }
  end

  def handle_api_error(error)
    Rails.logger.error "Exchange rate API error: #{error.message}"
    raise error
  end
end