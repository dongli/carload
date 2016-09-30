module Carload
  module ApplicationHelper
    def needs_upload? model_name, attribute_name
      case Carload.upload_solution
      when :carrierwave
        model_class = model_name.to_s.classify.constantize
        not model_class.instance_methods.map(&:to_s).select { |x| x =~ /#{attribute_name}_url/ }.empty?
      end
    end

    def image? attribute_name
      attribute_name.to_s =~ /image|logo|img/
    end
  end
end
