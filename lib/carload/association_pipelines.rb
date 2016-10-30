module Carload
  module AssociationPipelines
    def association_pipelines
      [ :pipeline_1, :pipeline_2, :pipeline_3 ]
    end

    # Find polymorphic instance models.
    def pipeline_1 association
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
    def pipeline_2 association
      return unless associated_model = @associated_models[association.name.to_s.singularize.to_sym]
      model = association.name.to_s.singularize.camelize.constantize rescue return
      associated_model[:attributes] ||= []
      associated_model[:attributes] = model.column_names - ModelSpec::SkippedAttributes
      associated_model[:attributes] = associated_model[:attributes] - [
        "#{@name}_id",
        "#{associated_model[:polymorphic]}_id",
        "#{associated_model[:polymorphic]}_type"
      ]
    end

    # Add has-many permitted attribute.
    def pipeline_3 association
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
