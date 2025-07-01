# frozen_string_literal: true

# Namespace for Vancouver City API integration services
module External::VancouverCity
  # Convenience method to get default API client
  def self.default_client
    VancouverApiClient.default_client
  end
end
