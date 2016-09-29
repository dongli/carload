module Carload
  class ExtendedHash < Hash
    def method_missing method, *args, &block
      key = method.to_s.gsub('=', '').to_sym
      if method.to_s =~ /=$/
        self[key] = args.first
      else
        self[key]
      end
    end
  end
end
