# Debug URL construction
require_relative 'vancouver_api_client'

# Test basic connection
client = VancouverApi::VancouverApiClient.new

begin
  puts "Testing with debug..."
  
  # Get the connection and test it manually
  connection = client.instance_variable_get(:@connection)
  puts "Base URL: #{connection.url_prefix}"
  
  # Manually construct and test the path
  dataset_id = 'drinking-fountains'
  path = "/catalog/datasets/#{dataset_id}/records"
  params = { limit: 5 }
  
  puts "Full URL would be: #{connection.url_prefix}#{path}"
  puts "Params: #{params.inspect}"
  
  # Make a raw request without response processing
  response = connection.get(path, params)
  puts "Raw response status: #{response.status}"
  puts "Raw response headers: #{response.headers.inspect}"
  puts "Raw response body (first 200 chars): #{response.body[0..200]}"
  
rescue => e
  puts "Error occurred: #{e.class}"
  puts "Error message: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(5)
end
