module ExchangeRates
	class Create
		include Interactor
	
		delegate :params, to: :context

		def call
		  context.exchange_rate = ExchangeRate.create!(params)
		rescue => e
			context.fail!(message: e.message)
		end
	end
end

	
