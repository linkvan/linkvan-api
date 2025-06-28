# Debug URL construction more carefully
require 'faraday'
require 'uri'

# Test different URL constructions
base_url = 'https://opendata.vancouver.ca/api/explore/v2.1'
path = '/catalog/datasets/drinking-fountains/records'
params = { limit: 5 }

puts "=== Testing URL Construction ==="
puts "Base URL: #{base_url}"
puts "Path: #{path}"
puts "Params: #{params.inspect}"

# Test 1: Direct URL construction like curl
full_url = "#{base_url}#{path}?#{URI.encode_www_form(params)}"
puts "\nFull URL: #{full_url}"

connection = Faraday.new
puts "\nTesting direct URL with Faraday..."
response = connection.get(full_url)
puts "Status: #{response.status}"
puts "Content-Type: #{response.headers['content-type']}"
puts "Body preview: #{response.body[0..100]}"

puts "\n" + "="*60

# Test 2: Faraday connection with path and params separately
puts "Testing with Faraday connection object..."
connection2 = Faraday.new(base_url)
response2 = connection2.get(path, params)
puts "Status: #{response2.status}"
puts "Content-Type: #{response2.headers['content-type']}"
puts "Body preview: #{response2.body[0..100]}"

puts "\n" + "="*60

# Test 3: Debug the actual URL Faraday is building
puts "Testing what URL Faraday actually builds..."
connection3 = Faraday.new(base_url) do |conn|
  conn.response :logger, nil, { headers: true, bodies: true } do |logger|
    logger.filter(/(Authorization: )(.*)/, '\1[REDACTED]')
  end
end

puts "Making request with logging..."
response3 = connection3.get(path, params)
