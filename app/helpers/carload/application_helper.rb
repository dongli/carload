module Carload
  module ApplicationHelper
    def needs_upload? model_name, attribute_name
      case Carload.upload_solution
      when :carrierwave
        model_class = model_name.to_s.classify.constantize
        not model_class.instance_methods.map(&:to_s).select { |x| x =~ /#{attribute_name}_url/ }.empty?
      end
    end

    def polymorphic? attribute_name
      Dashboard.model(@model_name).associations.each_value do |association|
        reflection = association[:reflection]
        return reflection.name if attribute_name =~ /#{reflection.name}/ and reflection.options[:polymorphic]
      end
      false
    end

    def image? attribute_name
      attribute_name.to_s =~ /image|logo|img/
    end

    def associated_model_name model_name, attribute_name
      x = attribute_name.gsub(/_ids?$/, '').to_sym
      Dashboard.model(model_name).associations.each do |name, association|
        return association[:class_name] || x, name if name.to_s.singularize.to_sym == x
      end
      raise 'Should not go here!'
    end

    def id_or_ids reflection
      case reflection
      when ActiveRecord::Reflection::HasManyReflection
        "#{reflection.name.to_s.singularize}_ids"
      else
        "#{reflection.name}_id"
      end
    end
  end
end
