# frozen_string_literal: true

require_relative 'vancouver_api_client'

# Examples of different ways to create and use adapters with the mandatory pattern

puts "=== Vancouver API Client - Mandatory Adapter Examples ==="
puts

# Option 1: Using the class-level default adapter (simplest)
puts "1. Using default adapter:"
client1 = VancouverApi::VancouverApiClient.new(
  adapter: VancouverApi::VancouverApiClient.default_adapter
)
puts "   ✓ Client created with default adapter"
puts

# Option 2: Using default adapter with custom timeouts
puts "2. Using default adapter with custom timeouts:"
client2 = VancouverApi::VancouverApiClient.new(
  adapter: VancouverApi::VancouverApiClient.default_adapter(timeout: 60, open_timeout: 20)
)
puts "   ✓ Client created with custom timeout configuration"
puts

# Option 3: Creating a fully custom adapter
puts "3. Using fully custom adapter:"
custom_adapter = VancouverApi::Adapters::FaradayAdapter
  .builder('https://opendata.vancouver.ca/api/explore/v2.1')
  .timeout(120)
  .open_timeout(30)
  .user_agent('My Custom Vancouver Client v1.0')
  .header('X-Custom-Header', 'custom-value')
  .header('X-API-Version', '2.1')
  .build

client3 = VancouverApi::VancouverApiClient.new(adapter: custom_adapter)
puts "   ✓ Client created with fully custom adapter"
puts

# Option 4: Different base URLs (for testing or different environments)
puts "4. Using adapter with different base URL:"
test_adapter = VancouverApi::Adapters::FaradayAdapter
  .builder('https://test-api.vancouver.ca/api/explore/v2.1')
  .timeout(30)
  .open_timeout(10)
  .user_agent('Test Client')
  .build

client4 = VancouverApi::VancouverApiClient.new(adapter: test_adapter)
puts "   ✓ Client created with test environment adapter"
puts

# Option 5: For testing - using a mock adapter
puts "5. For testing - mock adapter example:"
puts "   class MockAdapter"
puts "     def get(path, params = {})"
puts "       # Return mock response"
puts "     end"
puts "   end"
puts "   "
puts "   client = VancouverApiClient.new(adapter: MockAdapter.new)"
puts "   ✓ Perfect for unit testing!"
puts

puts "=== Key Benefits of Mandatory Adapter Pattern ==="
puts "✓ Explicit dependency injection - no hidden defaults"
puts "✓ Easy to test with mock adapters"
puts "✓ Flexible configuration without complex constructors"
puts "✓ Clear separation of HTTP concerns from business logic"
puts "✓ Easy to swap adapters for different environments"
puts

# Demonstrate that the adapter is actually being used
puts "=== Verification that adapters work ==="
begin
  adapter_info = client1.instance_variable_get(:@adapter)
  puts "Default adapter timeout: #{adapter_info.options.timeout}s"
  puts "Default adapter URL: #{adapter_info.url_prefix}"
  puts "Default adapter User-Agent: #{adapter_info.headers['User-Agent']}"
  
  custom_adapter_info = client3.instance_variable_get(:@adapter)
  puts "Custom adapter timeout: #{custom_adapter_info.options.timeout}s"
  puts "Custom adapter User-Agent: #{custom_adapter_info.headers['User-Agent']}"
  puts "Custom adapter has custom header: #{custom_adapter_info.headers.key?('X-Custom-Header')}"
  
rescue => e
  puts "Error: #{e.message}"
end
