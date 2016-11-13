module Carload
  module AssociationPipelines
    def associated_model_name association
      if association.options[:class_name]
        association.options[:class_name].to_s.underscore.to_sym
      else
        association.name.to_s.singularize.to_sym
      end
    end

    def association_pipelines
      [ :pipeline_1, :pipeline_2, :pipeline_3, :pipeline_4 ]
    end

    # Check if association model is renamed.
    def pipeline_1 association
      if association.options[:class_name]
        model_name = associated_model_name(association)
        model_rename = association.name.to_s.singularize.to_sym
        @associated_models[model_name][:rename] = model_rename
        @attributes[:permitted].map! do |attribute|
          case attribute
          when Symbol
            if attribute.to_s =~ /#{model_name}/
              attribute.to_s.gsub(model_name.to_s, model_rename.to_s).to_sym
            end
          when Hash
            if attribute.keys.first.to_s =~ /#{model_name}/
              { attribute.keys.first.to_s.gsub(model_name.to_s, model_rename.to_s).to_sym => [] }
            end
          end
        end
      end
    end

    # Find polymorphic instance models.
    def pipeline_2 association
      return unless association.options[:polymorphic]
      associated_model = @associated_models[association.name]
      ActiveRecord::Base.descendants.each do |model|
        next if model.name == 'ApplicationRecord' or model.name.underscore == @name.to_s
        model.reflect_on_all_associations.each do |model_association|
          next unless model_association.options[:as] == association.name
          associated_model[:instance_models] ||= []
          associated_model[:instance_models] << model.name.underscore.to_sym
          if not associated_model[:attributes]
            associated_model[:attributes] = model.column_names - ModelSpec::SkippedAttributes
          else
            associated_model[:attributes] = associated_model[:attributes] & model.column_names
          end
        end
      end
    end

    # Add possible attributes to let user choose.
    def pipeline_3 association
      model_name = associated_model_name(association)
      return unless associated_model = @associated_models[model_name]
      model = model_name.to_s.camelize.constantize rescue return
      associated_model[:attributes] ||= []
      associated_model[:attributes] = model.column_names - ModelSpec::SkippedAttributes
      associated_model[:attributes] = associated_model[:attributes] - [
        "#{@name}_id",
        "#{associated_model[:polymorphic]}_id",
        "#{associated_model[:polymorphic]}_type"
      ]
    end

    # Add has-many permitted attribute.
    def pipeline_4 association
      _association = (association.delegate_reflection rescue nil) || association
      return unless _association.class == ActiveRecord::Reflection::HasManyReflection
      # Exclude join table.
      return unless @klass.reflect_on_all_associations.select { |x| x.options[:through] == _association.name }.empty?
      @attributes[:permitted].each do |permitted|
        next unless permitted.class == Hash
        return if permitted.keys.first == :"#{_association.class_name.underscore}_ids"
      end
      @attributes[:permitted] << { :"#{_association.class_name.underscore}_ids" => [] }
    end
  end
end
