class CurrenciesController < ApplicationController
  def convert
  end

  private

  def convert_params
    params.permit(:from_currency, :to_currency, :amount)
  end
end