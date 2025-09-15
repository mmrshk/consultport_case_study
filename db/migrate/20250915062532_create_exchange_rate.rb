class CreateExchangeRate < ActiveRecord::Migration[7.1]
  def change
    create_table :exchange_rates do |t|
      t.string :from, null: false
      t.string :provider, null: false
      t.decimal :rate, null: false
      t.string :to, null: false

      t.timestamps
    end
  end
end
