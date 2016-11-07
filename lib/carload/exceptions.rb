module Carload
  class Error < StandardError
    attr_reader :message
  end

  class UnmanagedModelError < Error
    def initialize data
      @message = I18n.t('carload.error.message.unmanaged_model', model: data)
    end
  end

  class UnsupportedError < Error
    def initialize data
      @message = "Carload does not support #{data} currently."
    end
  end

  class InvalidError < Error
    def initialize data
      @message = data
    end
  end
end
