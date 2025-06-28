# frozen_string_literal: true

# Example usage of the Vancouver API Client
# This script demonstrates how to fetch drinking fountains data from Vancouver's Open Data API

require_relative 'vancouver_api_client'

# Initialize the client
client = VancouverApi::VancouverApiClient.new

begin
  # Example 1: Get the first 20 drinking fountains
  puts "=== Example 1: First 20 drinking fountains ==="
  response = client.get_dataset_records('drinking-fountains', limit: 20)
  
  if response.success?
    data = response.body
    puts "Total records available: #{data['total_count']}"
    puts "Records returned: #{data['results']&.length || 0}"
    
    # Display first few records
    if data['results'] && data['results'].any?
      puts "\nFirst 3 records:"
      data['results'].first(3).each_with_index do |record, index|
        puts "#{index + 1}. #{record.inspect}"
      end
    end
  else
    puts "Failed to fetch data: #{response.status}"
  end

  # Example 2: Get drinking fountains with specific fields only
  puts "\n=== Example 2: Specific fields only ==="
  response = client.get_dataset_records('drinking-fountains', 
    select: 'name,location,geom',
    limit: 5
  )
  
  if response.success?
    data = response.body
    puts "Records with selected fields:"
    data['results']&.each_with_index do |record, index|
      puts "#{index + 1}. Name: #{record['name']}, Location: #{record['location']}"
    end
  end

  # Example 3: Get dataset information
  puts "\n=== Example 3: Dataset information ==="
  dataset_response = client.get_dataset('drinking-fountains')
  
  if dataset_response.success?
    dataset_info = dataset_response.body
    puts "Dataset ID: #{dataset_info['dataset_id']}"
    puts "Dataset Title: #{dataset_info['metas']&.dig('default', 'title')}"
    puts "Total records: #{dataset_info['metas']&.dig('default', 'records_count')}"
    
    # Show available fields
    if dataset_info['fields']
      puts "\nAvailable fields:"
      dataset_info['fields'].each do |field|
        puts "- #{field['name']} (#{field['type']}): #{field['label']}"
      end
    end
  end

  # Example 4: Search with filters (if applicable)
  puts "\n=== Example 4: Filtered search ==="
  # Note: This example assumes there might be filterable fields
  # You may need to adjust the where clause based on actual field names
  filtered_response = client.get_dataset_records('drinking-fountains',
    limit: 10,
    order_by: 'name asc'  # Order by name if available
  )
  
  if filtered_response.success?
    data = filtered_response.body
    puts "Filtered results (ordered by name):"
    data['results']&.first(5)&.each_with_index do |record, index|
      puts "#{index + 1}. #{record['name'] || 'Unnamed'}"
    end
  end

rescue VancouverApi::VancouverApiError => e
  puts "Vancouver API Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
  puts "Response Body: #{e.response_body}" if e.response_body
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "\n=== Usage Examples ==="
puts <<~USAGE
  # Basic usage:
  client = VancouverApi::VancouverApiClient.new
  
  # Get records with default parameters (limit: 10)
  response = client.get_dataset_records('drinking-fountains')
  
  # Get records with custom parameters
  response = client.get_dataset_records('drinking-fountains', 
    limit: 50,
    select: 'name,location,geom',
    order_by: 'name asc'
  )
  
  # Access the data
  data = response.body
  total_count = data['total_count']
  records = data['results']
  
  # Get dataset information
  dataset_info = client.get_dataset('drinking-fountains')
  
  # List all available datasets
  datasets = client.get_datasets(limit: 20)
USAGE
