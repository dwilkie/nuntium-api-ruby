class Nuntium
  class Exception < ::StandardError
    attr_accessor :properties

    def initialize(msg, properties = {})
      super msg
      @properties = properties
    end
  end
end
