module Currencies
	class ConvertInteractor
		include Interactor
	
		delegate :params, to: :context
	
		def call
			get_or_fetch_exchange_rate

			context.converted_amount = calculate_conversion
		end

		private

		def get_or_fetch_exchange_rate
			cached_rate = get_cached_exchange_rate

			context.exchange_rate = cached_rate ? cached_rate : fetch_exchange_rate
		end

		def fetch_exchange_rate
      fetched_exchange_rate = ExchangeRateApiService.new.fetch_rates(
        params[:from_currency], 
        params[:to_currency]
      )

			ExchangeRates::Create.call!(params: fetched_exchange_rate).exchange_rate
		rescue => e
      context.fail!(message: 'Failed to fetch or create exchange rate', errors: [e.message])
		end

		def get_cached_exchange_rate
			ExchangeRate.
				where(from: params[:from_currency], to: params[:to_currency]).
				where('created_at > ?', 24.hours.ago).
				first
		end

		def calculate_conversion
			context.conversion_result = CurrencyConversionService.new(
				context.exchange_rate.rate,
				params[:amount]
			).converted_amount
		end
	end
end