class ApplicationSerializer
  attr_reader :object

  def initialize(model_object)
    @object = model_object
  end

  def as_json(response = nil)
    case response
    when Hash
      result = response.with_indifferent_access
    else
      result = HashWithIndifferentAccess.new
    end

    serialized_obj = HashWithIndifferentAccess.new
    attributes.each do |field|
      serialized_obj[field.to_sym] = send(field)
    end
    return result.merge({ field_name => serialized_obj })
  end

  def serialize
    object.as_json
  end

  def attributes
    object.attribute_names
  end

  def field_name
    :facilities
  end

  def serializer_class
    raise NotImplementedError
  end

  def method_missing(meth, *args, &block)
    return object.send(meth, *args, &block) if object.respond_to?(meth)

    super
  end

  def respond_to_missing?(meth, include_private = false)
    result = super
    result = true if (!result && object.respond_to?(meth))
    result
  end

  # def respond_to?(meth)
  #   result = super
  #   result = true if (!result && object.respond_to?(meth))
  #   result
  # end
  
end
