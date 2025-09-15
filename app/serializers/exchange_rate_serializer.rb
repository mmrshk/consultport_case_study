class ExchangeRateSerializer < Panko::Serializer
	attributes :id, :from, :to, :rate, :provider
end
  