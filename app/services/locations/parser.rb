module Locations
  module Parser
    GeoCoderLocation = Struct.new(:address,
                                  :city,
                                  :state,
                                  :country,
                                  :postal_code,
                                  :latitude,
                                  :longitude,
                                  :data,
                                  keyword_init: true)

    class << self
      def parse(geocoded_result, provider: nil)
        provider_class(provider)
          .call(geocoded_result)
      end

      def provider_class(provider = nil)
        provider_class_name(provider).constantize
      end

      def provider_class_name(provider_name = nil)
        provider = provider_name || provider_from_config

        "Locations::Providers::#{provider.to_s.camelcase}Parser"
      end

      def provider_from_config
        Geocoder.config.lookup
      end
    end
  end
end
