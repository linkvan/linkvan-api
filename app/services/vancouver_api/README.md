# Vancouver Open Data API Client

A Ruby HTTP client for the Vancouver Open Data API (Opendatasoft Explore API v2.1) using the Faraday gem.

## Overview

This client provides easy access to Vancouver's open data portal at `https://opendata.vancouver.ca/api/explore/v2.1/`. It's specifically designed to work with the drinking fountains dataset and other datasets available through the portal.

## Features

- Simple, intuitive interface for querying datasets
- Support for all ODSQL query parameters (filtering, sorting, pagination, etc.)
- Automatic JSON parsing of responses
- Comprehensive error handling with custom error types
- Built-in timeout configuration
- Detailed documentation and examples

## Usage

### Basic Usage

```ruby
require_relative 'vancouver_api_client'

# Simplest approach - use the default client
client = VancouverApi::VancouverApiClient.default

# Or use the module constant directly
client = VancouverApi::VancouverApiClient.new(adapter: VancouverApi::DEFAULT_ADAPTER)

# Get drinking fountains data
response = client.get_dataset_records('drinking-fountains', limit: 20)
data = response.body

puts "Total fountains: #{data['total_count']}"
puts "Records returned: #{data['results'].length}"

# Access individual records
data['results'].each do |fountain|
  puts "#{fountain['name']} - #{fountain['location']}"
end
```

### Advanced Queries

```ruby
# Create client with default configuration
client = VancouverApi::VancouverApiClient.default

# Get specific fields only
response = client.get_dataset_records('drinking-fountains', 
  select: 'name,location,geom',
  limit: 50
)

# Filter and sort results
response = client.get_dataset_records('drinking-fountains',
  where: 'maintainer = "Parks"',
  order_by: 'name asc',
  limit: 100
)

# Get dataset information
dataset_info = client.get_dataset('drinking-fountains')
puts "Dataset: #{dataset_info.body['metas']['default']['title']}"
puts "Total records: #{dataset_info.body['metas']['default']['records_count']}"

# List available datasets
datasets = client.get_datasets(limit: 50)
```

### Configuration

```ruby
# Method 1: Use convenience methods
client = VancouverApi::VancouverApiClient.with_timeouts(timeout: 60, open_timeout: 20)

# Method 2: Use VancouverApiConfig for complex configurations
config = VancouverApi::VancouverApiConfig.new(
  base_url: 'https://opendata.vancouver.ca/api/explore/v2.1',
  timeout: 60,
  open_timeout: 20
)
client = VancouverApi::VancouverApiClient.with_config(config)

# Method 3: Create fully custom adapter
custom_adapter = VancouverApi::Adapters::FaradayAdapter
  .builder('https://api.example.com')
  .timeout(120)
  .open_timeout(30)
  .user_agent('My Custom Client')
  .header('Authorization', 'Bearer token')
  .build

client = VancouverApi::VancouverApiClient.new(adapter: custom_adapter)

# Method 4: Environment-specific configurations
production_config = VancouverApi::VancouverApiConfig.new(timeout: 60)
test_config = VancouverApi::VancouverApiConfig.new(
  base_url: 'https://test-api.vancouver.ca/api/explore/v2.1',
  timeout: 30
)

prod_client = VancouverApi::VancouverApiClient.with_config(production_config)
test_client = VancouverApi::VancouverApiClient.with_config(test_config)
```

## Architecture

The client uses a layered architecture with clear separation of concerns:

### Configuration Layer - VancouverApiConfig

The `VancouverApiConfig` class centralizes all configuration options:

```ruby
config = VancouverApi::VancouverApiConfig.new(
  base_url: 'https://opendata.vancouver.ca/api/explore/v2.1',  # API base URL
  timeout: 30,                                                  # Request timeout (seconds)
  open_timeout: 10                                             # Connection timeout (seconds)
)
```

### Adapter Layer - FaradayAdapter

The `FaradayAdapter` class wraps the Faraday HTTP client and provides:

- **Builder Pattern**: Fluent interface for configuration
- **HTTP Method Delegation**: Clean interface for GET, POST, PUT, DELETE, PATCH
- **Configuration Integration**: Can be created from VancouverApiConfig objects

```ruby
# From configuration
adapter = VancouverApi::Adapters::FaradayAdapter.create(config)

# Or with builder pattern
adapter = VancouverApi::Adapters::FaradayAdapter
  .builder('https://opendata.vancouver.ca/api/explore/v2.1')
  .timeout(60)
  .open_timeout(20)
  .user_agent('Custom User Agent')
  .header('X-Custom-Header', 'value')
  .build
```

### Client Layer - VancouverApiClient

The main client provides multiple creation methods and handles business logic:

```ruby
# Convenience methods
client = VancouverApi::VancouverApiClient.default
client = VancouverApi::VancouverApiClient.with_timeouts(timeout: 60)
client = VancouverApi::VancouverApiClient.with_config(config)

# Direct instantiation (for testing)
client = VancouverApi::VancouverApiClient.new(adapter: adapter)
```

### Default Configuration

The module provides a ready-to-use default adapter:

```ruby
# Available as a module constant
VancouverApi::DEFAULT_ADAPTER

# Used by the convenience .default method
client = VancouverApi::VancouverApiClient.default  # Uses DEFAULT_ADAPTER
```

### Testing with Mock Adapters

The configuration-based architecture makes testing easier:

```ruby
# In your tests
RSpec.describe YourService do
  let(:mock_adapter) { instance_double(VancouverApi::Adapters::FaradayAdapter) }
  let(:client) { VancouverApi::VancouverApiClient.new(adapter: mock_adapter) }

  it 'calls the API correctly' do
    mock_response = instance_double(Faraday::Response, body: { 'results' => [] })
    allow(mock_adapter).to receive(:get).and_return(mock_response)
    
    client.get_dataset_records('test-dataset')
    
    expect(mock_adapter).to have_received(:get).with('/catalog/datasets/test-dataset/records', anything)
  end
end

# Or test with different configurations
describe 'with production config' do
  let(:prod_config) { VancouverApi::VancouverApiConfig.new(timeout: 60) }
  let(:client) { VancouverApi::VancouverApiClient.with_config(prod_config) }
  
  # Test production-specific behavior
end
```

## API Methods

### `get_dataset_records(dataset_id, **options)`

Retrieve records from a dataset.

**Parameters:**

- `dataset_id` (String): Dataset identifier (e.g., 'drinking-fountains')
- `options` (Hash): Query parameters

**Supported Options:**

- `:select` - Fields to select (default: '*' for all fields)
- `:where` - Filter expression using ODSQL
- `:order_by` - Sort expression (e.g., 'name asc')
- `:limit` - Number of records to return (max 100, default 10)
- `:offset` - Starting index for pagination (default 0)
- `:group_by` - Group by expression for aggregations
- `:refine` - Facet refinement (e.g., 'field:value')
- `:exclude` - Facet exclusion (e.g., 'field:value')
- `:lang` - Language for formatting (default 'en')
- `:timezone` - Timezone for date formatting
- `:include_links` - Whether to include navigation links
- `:include_app_metas` - Whether to include application metadata

### `get_dataset(dataset_id, **options)`

Get information about a specific dataset.

### `get_datasets(**options)`

List all available datasets.

### `get_dataset_record(dataset_id, record_id, **options)`

Get a specific record from a dataset.

## Response Structure

All successful API calls return a Faraday::Response object with a parsed JSON body:

```ruby
response = client.get_dataset_records('drinking-fountains', limit: 5)

# Response data
data = response.body
total_count = data['total_count']    # Total number of records available
results = data['results']            # Array of records

# Individual record structure
record = results.first
puts record['mapid']                 # Unique identifier
puts record['name']                  # Fountain name/location
puts record['location']              # Specific location description
puts record['geom']                  # Geographic coordinates
```

## Error Handling

The client raises `VancouverApi::VancouverApiError` for API errors:

```ruby
begin
  response = client.get_dataset_records('invalid-dataset')
rescue VancouverApi::VancouverApiError => e
  puts "Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
  puts "Response Body: #{e.response_body}" if e.response_body
end
```

## Example: Working with Drinking Fountains

```ruby
client = VancouverApi::VancouverApiClient.new

# Get all fountains in downtown area
downtown_fountains = client.get_dataset_records('drinking-fountains',
  where: 'geo_local_area = "Downtown"',
  order_by: 'name asc'
)

downtown_fountains.body['results'].each do |fountain|
  coords = fountain['geo_point_2d']
  puts "#{fountain['name']}"
  puts "  Location: #{fountain['location']}"
  puts "  Coordinates: #{coords['lat']}, #{coords['lon']}"
  puts "  Operational: #{fountain['in_operation']}"
  puts
end
```

## Dependencies

- `faraday` gem (~> 2.13.1) - Already included in the project's Gemfile
- `json` gem - Part of Ruby standard library

## API Documentation

For more information about the underlying API and ODSQL query language, see:

- [Opendatasoft Explore API Documentation](https://help.opendatasoft.com/apis/ods-explore-v2/)
- [ODSQL Reference](https://help.opendatasoft.com/apis/ods-explore-v2/#section/Opendatasoft-Query-Language-(ODSQL))

## Files

- `vancouver_api_client.rb` - Main client implementation with convenience methods
- `adapters/faraday_adapter.rb` - HTTP adapter with builder pattern and config integration
- `config_examples.rb` - Comprehensive usage examples with new configuration structure
- `openapi.json` - API specification for reference
