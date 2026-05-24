# frozen_string_literal: true

class External::SyncOperations
  class << self
    def unexpected_error
      @unexpected_error ||= UnexpectedError.new
    end

    def unknown
      @unknown ||= Unknown.new
    end

    def api_call
      @api_call ||= ApiCall.new
    end

    def create
      @create ||= Create.new
    end

    def external_update
      @external_update ||= ExternalUpdate.new
    end

    def internal_update
      @internal_update ||= InternalUpdate.new
    end

    def discard
      @discard ||= Discard.new
    end
  end

  class Base
    def name
      throw NotImplementedError, "Subclasses must implement the name method"
    end
  end

  class Create < Base
    def name
      "create"
    end
  end

  class ExternalUpdate < Base
    def name
      "update"
    end
  end

  class InternalUpdate < Base
    def name
      "update"
    end
  end

  class Discard < Base
    def name
      "discard"
    end
  end

  class ApiCall < Base
    def name
      "api call"
    end
  end

  class Unknown < Base
    def name
      "unknown"
    end
  end

  class UnexpectedError < Base
    def name
      "unexpected error"
    end
  end
end
