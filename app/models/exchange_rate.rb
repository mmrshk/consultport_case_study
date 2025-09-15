# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string           not null
#  provider   :string           not null
#  rate       :decimal(, )      not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ExchangeRate < ApplicationRecord
  validates :from, :to, :provider, :rate, presence: true
  validates :provider, uniqueness: { scope: %i[from to] }
  validates :rate, numericality: { greater_than: 0 }
end
