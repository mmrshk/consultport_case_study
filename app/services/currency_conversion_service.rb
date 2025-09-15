# frozen_string_literal: true

class CurrencyConversionService
  def initialize(exchange_rate, amount)
    @exchange_rate = exchange_rate
    @amount = amount
  end

  def converted_amount
		(amount.to_f * exchange_rate).round(2)
  end

  private

	attr_reader :amount, :exchange_rate
end
