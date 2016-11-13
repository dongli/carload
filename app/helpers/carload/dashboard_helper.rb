module Carload
  module DashboardHelper
    def generate_input form, model_name, attribute_name, options = {}
      if options[:polymorphic]
        form.input attribute_name,
          collection: @model_class.send(attribute_name.to_s.pluralize),
          selected: options[:value],
          input_html: { class: 'use-select2' }
      elsif attribute_name =~ /_id$/
        associated_model = attribute_name.gsub(/_id$/, '').to_sym
        association_specs = Dashboard.model(model_name).associated_models[associated_model]
        label_attribute = association_specs[:choose_by]
        form.association associated_model,
          label_method: label_attribute,
          label: t("activerecord.models.#{associated_model}"),
          input_html: {
            class: 'use-select2',
            data: {
              placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{associated_model}.#{label_attribute}"))
            }
          }
      elsif attribute_name =~ /_ids$/
        # Mandle many-to-many association.
        associated_model = attribute_name.gsub(/_ids$/, '').to_sym
        association_specs = Dashboard.model(model_name).associated_models[associated_model]
        if Dashboard.model(model_name).associated_models[associated_model][:rename]
          renamed_associated_model = Dashboard.model(model_name).associated_models[associated_model][:rename]
          attribute_name = "#{renamed_associated_model}_ids"
        end
        label_attribute = association_specs[:choose_by]
        form.input attribute_name,
          label: t("activerecord.attributes.#{associated_model}.#{label_attribute}") + " (#{t("activerecord.models.#{associated_model}")})",
          collection: associated_model.to_s.camelize.constantize.all,
          label_method: label_attribute,
          value_method: :id,
          input_html: {
            class: 'use-select2',
            multiple: true,
            data: {
              placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{associated_model}.#{label_attribute}"))
            }
          }
      elsif attribute_name =~ /_type$/
        associated_model = attribute_name.gsub(/_type$/, '').to_sym
        association_specs = Dashboard.model(model_name).associated_models[associated_model]
        form.input attribute_name, collection: association_specs[:instance_models].map{ |x| x.to_s.camelize },
          input_html: {
            class: 'use-select2',
            data: {
              placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{model_name}.#{attribute_name}"))
            }
          }
      elsif needs_upload?(model_name, attribute_name) and image?(attribute_name)
        upload_image form: form, image_name: attribute_name, width: 150, height: 150
      elsif options[:type] == :text
        form.input(attribute_name, label: raw(<<-EOT
          <span class="control-label string optional">#{t("activerecord.attributes.#{@model_name}.#{attribute_name}")}</span>
          <a id='preview-#{attribute_name}-button' class='btn btn-xs' data-toggle='on'>#{t('carload.action.preview')} (Markdown)</a>
        EOT
        )) + raw(<<-EOT
          <script>
            $('.#{@model_name}_#{attribute_name}').append("<div id='preview-#{attribute_name}-content' class='markdown-preview'></div>")
            $('#preview-#{attribute_name}-button').click(function() {
              if ($(this).data('toggle') == 'on') {
                var md = new Remarkable()
                var marked_content = md.render($('##{@model_name}_#{attribute_name}').val())
                $('##{@model_name}_#{attribute_name}').hide()
                $('#preview-#{attribute_name}-content').html(marked_content)
                $('#preview-#{attribute_name}-content').show()
                $(this).data('toggle', 'off')
                $(this).html('#{t('carload.action.edit')} (Markdown)')
              } else if ($(this).data('toggle') == 'off') {
                $('##{@model_name}_#{attribute_name}').show()
                $('#preview-#{attribute_name}-content').hide()
                $(this).data('toggle', 'on')
                $(this).html('#{t('carload.action.preview')} (Markdown)')
              }
            })
          </script>
        EOT
        )
      else
        form.input attribute_name
      end
    end

    def generate_show_title attribute
      case attribute
      when Symbol
        begin
          t("activerecord.attributes.#{@model_name}.#{attribute}", raise: true)
        rescue
          t("carload.activerecord.#{attribute}", raise: true)
        end
      when String
        begin
          t("activerecord.attributes.#{@model_name}.#{attribute}", raise: true)
        rescue
          "#{t("activerecord.attributes.#{attribute}", raise: true)} (#{t("activerecord.models.#{attribute.split('.').first.to_s.singularize}", raise: true)})"
        end
      when Array
        if attribute.first == :pluck
          raise UnsupportedError.new("attribute #{attribute}") if attribute.size != 3
          model_name = attribute[1].to_s.singularize
          attribute_name = attribute[2]
          begin
            "#{t("activerecord.attributes.#{model_name}.#{attribute_name}", raise: true)} (#{t("activerecord.models.#{model_name}", raise: true)})"
          rescue
            "#{t("activerecord.attributes.#{@model_name}.#{model_name}.#{attribute_name}", raise: true)}"
          end
        else
          "#{t("activerecord.attributes.#{attribute.join('.')}", raise: true)} (#{t("activerecord.models.#{attribute[0].to_s.singularize}", raise: true)})"
        end
      end
    end

    def generate_show object, attribute
      case attribute
      when Symbol
        object.send attribute
      when String
        res = eval "object.#{attribute.gsub('.', '&.')}"
        case res
        when String
          res
        when Array
          raw res.map { |x| "<span class='label label-primary'>#{x}</span>" }.join(' ')
        end
      when Array
        if attribute.first == :pluck
          raise UnsupportedError.new("attribute #{attribute}") if attribute.size != 3
          generate_show object, "#{attribute[1].to_s.pluralize}.pluck(:#{attribute[2]})"
        else
          generate_show object, attribute.join('.')
        end
      end
    end
  end
end
