module Carload
  class ModelSpec
    include AssociationPipelines

    attr_accessor :name, :klass, :default, :attributes, :index_page, :associated_models

    SkippedAttributes = [
      'id', 'created_at', 'updated_at',
      'encrypted_password', 'reset_password_token',
      'reset_password_sent_at', 'remember_created_at',
      'sign_in_count', 'current_sign_in_at',
      'last_sign_in_at', 'current_sign_in_ip',
      'last_sign_in_ip'
    ].freeze

    AssociationTypes = {
      ActiveRecord::Reflection::BelongsToReflection => :belongs_to,
      ActiveRecord::Reflection::HasOneReflection => :has_one,
      ActiveRecord::Reflection::HasManyReflection => :has_many,
      ActiveRecord::Reflection::ThroughReflection => :through
    }

    def initialize model_class = nil
      @default = false
      @attributes = ExtendedHash.new
      @index_page = ExtendedHash.new
      @index_page[:shows] = ExtendedHash.new
      @index_page[:shows][:attributes] ||= []
      @index_page[:searches] = ExtendedHash.new
      @index_page[:searches][:attributes] ||= []
      @associated_models = {}
      if model_class
        @name = model_class.name.underscore
        @klass = model_class
        @attributes[:permitted] = (model_class.column_names - SkippedAttributes).map(&:to_sym)
        # Handle model associations.
        model_class.reflect_on_all_associations.each do |association|
          handle_association association
        end
        @attributes[:permitted].each do |attribute|
          next if attribute.class == Hash
          @index_page[:shows][:attributes] << attribute
          @index_page[:searches][:attributes] << { name: attribute.to_sym, term: :cont }
        end
      end
    end

    def changed? spec
      not @default == spec.default or
      not @attributes[:permitted] == spec.attributes[:permitted] or
      not @index_page[:shows][:attributes] == spec.index_page[:shows][:attributes] or
      not @index_page[:searches][:attributes] == spec.index_page[:searches][:attributes]
    end

    def revise!
      # Handle associated models if necessary.
      @associated_models.each_value do |associated_model|
        next unless associated_model[:choose_by]
        if associated_model[:association_type] == :has_many
          show_name = [:pluck, associated_model[:name].to_s.pluralize.to_sym, associated_model[:choose_by]]
        else
          show_name = "#{associated_model[:name]}.#{associated_model[:choose_by]}"
        end
        @index_page[:shows][:attributes].delete_if { |x| x == :"#{associated_model[:name]}_id" }
        @index_page[:shows][:attributes] << show_name
      end
    end

    def handle_association association, options = {}
      begin
        _association = (association.delegate_reflection rescue nil) || association
        name = (_association.klass.name.underscore.to_sym rescue nil) || _association.name
        association_type = AssociationTypes[_association.class]
        polymorphic = association.options[:polymorphic] || association.options[:as]
        foreign_key =  @klass.column_names.include?("#{(_association.klass.name.underscore rescue nil) || _association.name}_id")
        join_table = association.options[:through].to_s.singularize.to_sym if association.options[:through]
        @associated_models[name] = {
          name: name,
          association_type: association_type,
          polymorphic: polymorphic,
          foreign_key: foreign_key,
          join_table: join_table,
          choose_by: nil
        }.merge @associated_models[name] || {}
        association_pipelines.each { |pipeline| send pipeline, association }
        # Delete join-table model!
        if association.options[:through]
          @associated_models.delete association.options[:through]
          @associated_models.delete association.options[:through].to_s.singularize.to_sym
        end
      rescue => e
        raise e unless options[:rescue]
        raise e if not e&.original_exception&.class == PG::UndefinedTable and
                   not e.class == ActiveRecord::NoDatabaseError
      end
    end
  end
end
