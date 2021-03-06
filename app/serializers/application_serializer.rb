class ApplicationSerializer
  attr_reader :object

  def initialize(model_object)
    @object = model_object
  end

  def as_json(response = nil)
    serialized_obj = HashWithIndifferentAccess.new
    attributes.each do |field|
      serialized_obj[field.to_sym] = send(field)
    end

    case response
    when Hash
      result = response.with_indifferent_access
      result = result.merge({ field_name => serialized_obj })
    else
      result = serialized_obj
    end

    result
  end

  def serialize
    object.as_json
  end

  def attributes
    object.attribute_names
  end

  protected
    def field_name
      NotImplementedError
    end

    def serializer_class
      raise NotImplementedError
    end

  private
    def method_missing(meth, *args, &block)
      return object.send(meth, *args, &block) if object.respond_to?(meth)

      super
    end

    def respond_to_missing?(meth, include_private = false)
      result = super
      result = true if !result && object.respond_to?(meth)
      result
    end

  # def respond_to?(meth)
  #   result = super
  #   result = true if (!result && object.respond_to?(meth))
  #   result
  # end
end
