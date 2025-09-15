# frozen_string_literal: true

class CurrenciesController < ApplicationController
  before_action :validate_currency_params, only: [:convert]

  def convert
    interactor = Currencies::ConvertInteractor.call(params: convert_params)

    if interactor.success?
      render json: { converted_amount: interactor.converted_amount }
    else
      render json: {
        message: interactor.message, errors: interactor.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def convert_params
    params.permit(:from_currency, :to_currency, :amount)
  end

  def validate_currency_params
    permitted = convert_params

    return unless permitted.values.any?(&:blank?)

    render json: {
      message: 'Missing required parameters'
    }, status: :unprocessable_content
  end
end