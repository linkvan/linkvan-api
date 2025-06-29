# Final integration test for the Vancouver API Client
require_relative 'vancouver_api_client'

def test_client
  client = External::VancouverCity::VancouverApiClient.new

  puts "=== Vancouver API Client Integration Test ==="
  
  # Test 1: Basic dataset records request
  puts "\n1. Testing basic dataset records request..."
  response = client.get_dataset_records('drinking-fountains', limit: 3)
  if response.success? && response.body['total_count'] > 0
    puts "✓ Success: Got #{response.body['results'].length} records"
  else
    puts "✗ Failed: Could not fetch records"
    return false
  end
  
  # Test 2: Dataset information
  puts "\n2. Testing dataset information..."
  dataset_response = client.get_dataset('drinking-fountains')
  if dataset_response.success? && dataset_response.body['dataset_id']
    puts "✓ Success: Got dataset info for '#{dataset_response.body['dataset_id']}'"
  else
    puts "✗ Failed: Could not fetch dataset info"
    return false
  end
  
  # Test 3: Datasets list
  puts "\n3. Testing datasets list..."
  datasets_response = client.get_datasets(limit: 5)
  if datasets_response.success? && datasets_response.body['total_count'] > 0
    puts "✓ Success: Got #{datasets_response.body['results'].length} datasets"
  else
    puts "✗ Failed: Could not fetch datasets list"
    return false
  end
  
  # Test 4: Query with parameters
  puts "\n4. Testing query with parameters..."
  filtered_response = client.get_dataset_records('drinking-fountains',
    select: 'mapid,name,location',
    order_by: 'name asc',
    limit: 5
  )
  if filtered_response.success? && filtered_response.body['results'].all? { |r| r.keys.sort == ['location', 'mapid', 'name'] }
    puts "✓ Success: Got filtered results with correct fields"
  else
    puts "✗ Failed: Query with parameters didn't work correctly"
    return false
  end
  
  # Test 5: Error handling
  puts "\n5. Testing error handling..."
  begin
    client.get_dataset_records('non-existent-dataset')
    puts "✗ Failed: Should have raised an error for non-existent dataset"
    return false
  rescue VancouverAPI::VancouverApiError => e
    puts "✓ Success: Properly handled error - #{e.message[0..50]}..."
  end
  
  puts "\n=== All tests passed! The client is working correctly. ==="
  return true
end

# Run the test
if test_client
  puts "\n🎉 Vancouver API Client is ready for use!"
else
  puts "\n❌ Some tests failed. Please check the implementation."
  exit 1
end
