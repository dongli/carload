module Carload
  class Dashboard
    class << self
      def model name, &block
        name = name.to_sym
        if block_given?
          @@models ||= {}
          spec = @@models[name] || ModelSpec.new
          spec.name = name
          yield spec
          @@models[name] = spec
        else
          @@models[name]
        end
      end

      def associate options
        model_a = options.keys.first
        model_b = options.values.first
        options.shift
        options[:name] = model_b
        @@models[model_a] ||= ModelSpec.new
        @@models[model_a].associated_models[model_b] = options
      end

      def models
        @@models ||= {}
      end

      def default_model
        return @@default_model if defined? @@default_model
        @@models.each do |name, spec|
          return @@default_model = name if spec.default
        end
        @@default_model = @@models.keys.first
      end

      def write file_path
        content = File.read("#{Carload::Engine.root}/lib/generators/carload/templates/dashboard.rb")
        content.gsub!(/^end$/, '')
        default = true
        models.each do |name, spec|
          content << <<-RUBY
  model :#{name} do |spec|
    spec.default = #{default}
    spec.attributes.permitted = #{spec.attributes.permitted}
    spec.index_page.shows.attributes = #{spec.index_page.shows.attributes}
    spec.index_page.searches.attributes = #{spec.index_page.searches.attributes}
  end
          RUBY
          default = false
          next if spec.associated_models.empty?
          spec.associated_models.each_value do |associated_model|
            next unless associated_model[:choose_by]
            content << <<-RUBY
  associate(#{{ name.to_sym => associated_model[:name], choose_by: associated_model[:choose_by].to_sym }})
            RUBY
          end
        end
        content << "end\n"
        File.open('app/carload/dashboard.rb', 'w') do |file|
          file.write content
          file.close
        end
      end
    end
  end
end
