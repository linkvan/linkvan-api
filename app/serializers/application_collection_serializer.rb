# frozen_string_literal: true

class ApplicationCollectionSerializer
  attr_reader :collection, :serializer_class

  def initialize(collection_object, serializer_class = nil)
    @serializer_class = serializer_class
    @collection = collection_object
  end

  def serialize(serializer_class)
    collection.map do |model_object|
      serializer_class.new(model_object).as_json
    end
  end

  def as_json(response = nil)
    case response
    when Hash
      response.with_indifferent_access
    else
      HashWithIndifferentAccess.new
    end
  end
end
