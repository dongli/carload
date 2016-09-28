module Carload
  class UnmanagedModelError < StandardError
    def initialize data
      @error = "You are trying to access unmanaged model #{data}!"
    end
  end
end
