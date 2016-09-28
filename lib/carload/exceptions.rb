module Carload
  class UnmanagedModelError < StandardError
    def initialize data
      @error = I18n.t('carload.error.message.unmanaged_model', model: data)
    end
  end
end
