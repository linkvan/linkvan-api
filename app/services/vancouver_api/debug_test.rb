# Simple test to debug the API client
require_relative 'vancouver_api_client'

# Test basic connection
client = VancouverApi::VancouverApiClient.new

begin
  puts "Testing API connection..."
  response = client.get_dataset_records('drinking-fountains', limit: 5)
  puts "Response status: #{response.status}"
  puts "Response headers: #{response.headers}"
  puts "Response body type: #{response.body.class}"
  puts "Response body: #{response.body}"
  
rescue => e
  puts "Error occurred: #{e.class}"
  puts "Error message: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(10)
end
