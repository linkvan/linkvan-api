# Test with minimal setup to compare with curl
require 'faraday'
require 'json'

# Test with bare minimum Faraday setup
connection = Faraday.new('https://opendata.vancouver.ca/api/explore/v2.1')

puts "Testing bare connection..."
response = connection.get('/catalog/datasets/drinking-fountains/records', { limit: 5 })
puts "Status: #{response.status}"
puts "Headers: #{response.headers['content-type']}"
puts "Body (first 100): #{response.body[0..100]}"

puts "\n" + "="*50

# Test with headers similar to curl
connection2 = Faraday.new('https://opendata.vancouver.ca/api/explore/v2.1') do |config|
  config.headers['User-Agent'] = 'curl/7.68.0'
  config.headers['Accept'] = '*/*'
end

puts "Testing with curl-like headers..."
response2 = connection2.get('/catalog/datasets/drinking-fountains/records', { limit: 5 })
puts "Status: #{response2.status}"
puts "Headers: #{response2.headers['content-type']}"
puts "Body (first 100): #{response2.body[0..100]}"
