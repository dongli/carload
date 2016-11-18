module Carload
  class ModelSpec
    attr_accessor :name, :klass, :default, :attributes, :index_page, :associations

    SkippedAttributes = [
      'id', 'created_at', 'updated_at',
      'encrypted_password', 'reset_password_token',
      'reset_password_sent_at', 'remember_created_at',
      'sign_in_count', 'current_sign_in_at',
      'last_sign_in_at', 'current_sign_in_ip',
      'last_sign_in_ip'
    ].freeze

    def initialize model_class = nil
      @default = false
      @attributes = ExtendedHash.new
      @index_page = ExtendedHash.new
      @index_page[:shows] = ExtendedHash.new
      @index_page[:shows][:attributes] ||= []
      @index_page[:searches] = ExtendedHash.new
      @index_page[:searches][:attributes] ||= []
      @associations ||= {}
      if model_class
        @name = model_class.name.underscore
        @klass = model_class
        @attributes[:permitted] = (model_class.column_names - SkippedAttributes).map(&:to_sym)
        @attributes[:permitted].each do |attribute|
          next if attribute.class == Hash
          @index_page[:shows][:attributes] << attribute
          @index_page[:searches][:attributes] << { name: attribute.to_sym, term: :cont }
        end
        model_class.reflect_on_all_associations.each do |reflection|
          @associations[reflection.name] = {
            reflection: reflection,
            choose_by: nil
          }
        end
        process_associaitons
      end
    end

    def process_associaitons
      @associations.each_value do |association|
        reflection = association[:reflection]
        if join_table = reflection.options[:through] and @associations.has_key? join_table
          # Filter join table.
          @associations.select { |k, v| v[:reflection].name == join_table }.values.first[:filtered] = true
          # Permit foreign id.
          case reflection.delegate_reflection
          when ActiveRecord::Reflection::HasOneReflection
            @attributes[:permitted] << :"#{reflection.delegate_reflection.name}_id"
          when ActiveRecord::Reflection::HasManyReflection
            @attributes[:permitted] << { :"#{reflection.delegate_reflection.name.to_s.singularize}_ids" => [] }
          end
        elsif reflection.options[:polymorphic]
          ActiveRecord::Base.descendants.each do |_model|
            next if _model.name == 'ApplicationRecord' or _model.name.underscore == @name.to_s
            _model.reflect_on_all_associations.each do |_reflection|
              next unless _reflection.options[:as] == reflection.name
              if association.has_key? :attributes
                association[:attributes] = association[:attributes] & _model.column_names
              else
                association[:attributes] = _model.column_names - SkippedAttributes
              end
              association[:instance_models] ||= []
              association[:instance_models] << _model.name.underscore.to_sym
            end
          end
          association[:attributes] = association[:attributes].map(&:to_sym)
        end
      end
    end

    def changed? spec
      not @default == spec.default or
      not @attributes[:permitted] == spec.attributes[:permitted] or
      not @index_page[:shows][:attributes] == spec.index_page[:shows][:attributes] or
      not @index_page[:searches][:attributes] == spec.index_page[:searches][:attributes]
    end
  end
end
