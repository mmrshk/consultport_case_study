# Currency Converter

This is a simple solution for currency conversion.
The main idea for improving the efficiency of this API was to introduce an `ExchangeRate` model, which stores exchange rates. When a conversion is requested, the system first checks if the rate already exists and uses the stored value, avoiding unnecessary external API calls.

To keep the data up to date, a Sidekiq scheduled task should run daily to fetch the latest exchange rates (Not Implemented).

The list of supported currencies should be carefully considered, as storing too many could unnecessarily increase database size.

The exact implementation depends on business needs:

- If historical accuracy is required (e.g., for invoices), you may want to store past rates permanently.

- If not needed, old rates can be safely removed each day to keep the database clean.


## The entrypoint:

- `CurrenciesController#convert`
