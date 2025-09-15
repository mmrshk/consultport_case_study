require 'webmock/rspec'

# Allow real HTTP connections for system tests
WebMock.disable_net_connect!(allow_localhost: true)

# Configure WebMock to work with HTTParty
WebMock::Config.instance.query_values_notation = :flat_array
