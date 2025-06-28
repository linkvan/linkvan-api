# frozen_string_literal: true

require_relative 'vancouver_api_client'

puts "=== Vancouver API Client - New Configuration-Based Structure ==="
puts

# Example 1: Using the default configuration (simplest)
puts "1. Using DEFAULT_ADAPTER constant:"
client1 = VancouverApi::VancouverApiClient.new(adapter: VancouverApi::DEFAULT_ADAPTER)
puts "   ✓ Client created with module-level default adapter"
puts

# Example 2: Using the convenience method
puts "2. Using convenience .default method:"
client2 = VancouverApi::VancouverApiClient.default
puts "   ✓ Client created with .default class method"
puts

# Example 3: Custom configuration with VancouverApiConfig
puts "3. Using custom VancouverApiConfig:"
config = VancouverApi::VancouverApiConfig.new(
  base_url: 'https://opendata.vancouver.ca/api/explore/v2.1',
  timeout: 60,
  open_timeout: 20
)
client3 = VancouverApi::VancouverApiClient.with_config(config)
puts "   ✓ Client created with custom configuration object"
puts

# Example 4: Quick timeout customization
puts "4. Using .with_timeouts convenience method:"
client4 = VancouverApi::VancouverApiClient.with_timeouts(timeout: 120, open_timeout: 30)
puts "   ✓ Client created with custom timeouts"
puts

# Example 5: Fully custom adapter for testing environments
puts "5. Using fully custom adapter:"
test_adapter = VancouverApi::Adapters::FaradayAdapter
  .builder('https://test-api.vancouver.ca/api/explore/v2.1')
  .timeout(45)
  .open_timeout(15)
  .user_agent('Test Client v2.0')
  .header('X-Environment', 'test')
  .build

client5 = VancouverApi::VancouverApiClient.new(adapter: test_adapter)
puts "   ✓ Client created with fully custom test adapter"
puts

# Example 6: Using VancouverApiConfig for different environments
puts "6. Environment-specific configurations:"

# Development config
dev_config = VancouverApi::VancouverApiConfig.new(
  timeout: 30,
  open_timeout: 10
)
dev_client = VancouverApi::VancouverApiClient.with_config(dev_config)
puts "   ✓ Development client created"

# Production config
prod_config = VancouverApi::VancouverApiConfig.new(
  timeout: 60,
  open_timeout: 20
)
prod_client = VancouverApi::VancouverApiClient.with_config(prod_config)
puts "   ✓ Production client created"

# Test config with different base URL
test_config = VancouverApi::VancouverApiConfig.new(
  base_url: 'https://staging-opendata.vancouver.ca/api/explore/v2.1',
  timeout: 45,
  open_timeout: 15
)
test_client = VancouverApi::VancouverApiClient.with_config(test_config)
puts "   ✓ Test client with staging URL created"
puts

puts "=== Benefits of the New Structure ==="
puts "✓ VancouverApiConfig centralizes configuration logic"
puts "✓ DEFAULT_ADAPTER provides a ready-to-use module constant"
puts "✓ Multiple convenience methods for different use cases"
puts "✓ Clear separation between config and HTTP adapter concerns"
puts "✓ Easy to create environment-specific configurations"
puts "✓ Still supports full customization when needed"
puts

# Verification
puts "=== Configuration Verification ==="
begin
  default_adapter_info = client1.instance_variable_get(:@adapter)
  puts "Default adapter timeout: #{default_adapter_info.options.timeout}s"
  puts "Default adapter URL: #{default_adapter_info.url_prefix}"
  
  custom_adapter_info = client3.instance_variable_get(:@adapter)
  puts "Custom config adapter timeout: #{custom_adapter_info.options.timeout}s"
  
  timeout_adapter_info = client4.instance_variable_get(:@adapter)
  puts "Timeout method adapter timeout: #{timeout_adapter_info.options.timeout}s"
  
  test_adapter_info = client5.instance_variable_get(:@adapter)
  puts "Test adapter URL: #{test_adapter_info.url_prefix}"
  puts "Test adapter has custom header: #{test_adapter_info.headers.key?('X-Environment')}"
  
rescue => e
  puts "Error: #{e.message}"
end

puts
puts "=== Usage Patterns ==="
puts "# Simplest usage:"
puts "client = VancouverApi::VancouverApiClient.default"
puts
puts "# With custom timeouts:"
puts "client = VancouverApi::VancouverApiClient.with_timeouts(timeout: 60)"
puts
puts "# With full configuration:"
puts "config = VancouverApi::VancouverApiConfig.new(timeout: 60, open_timeout: 20)"
puts "client = VancouverApi::VancouverApiClient.with_config(config)"
puts
puts "# For testing with mocks:"
puts "client = VancouverApi::VancouverApiClient.new(adapter: mock_adapter)"
