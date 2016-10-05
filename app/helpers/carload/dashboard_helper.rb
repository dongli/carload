module Carload
  module DashboardHelper
    def generate_input form, model_name, attribute_name, column
      if Dashboard::ModelSpec.foreign_key? attribute_name
        associated_model = attribute_name.gsub(/_id$/, '').to_sym
        options = Dashboard.model(model_name).associated_models[associated_model]
        label_attribute = options[:choose_by]
        if options[:polymorphic]
          forms = ''
          options[:available_models].each_with_index do |real_model, i|
            forms << form.input(attribute_name,
              label: t("activerecord.attributes.#{model_name}.#{real_model}.#{label_attribute}"),
              collection: real_model.camelize.constantize.all,
              label_method: label_attribute,
              value_method: :id,
              input_html: {
                class: 'use-select2',
                data: {
                  placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{real_model}.#{label_attribute}"))
                }
              },
              wrapper_html: {
                id: "#{real_model.camelize}-#{label_attribute}"
              }
            )
          end
          # Add JavaScript to select which real model to work on.
          forms << <<-EOT
            <script>
              $('.#{model_name}_#{associated_model}_id').hide()
              if ($('##{model_name}_#{associated_model}_type').val() != '') {
                $('#' + $('##{model_name}_#{associated_model}_type').val() + '-#{label_attribute}').show()
              }
              $('##{model_name}_#{associated_model}_type').change(function() {
                $('.#{model_name}_#{associated_model}_id').hide()
                $('#' + $(this).val() + '-#{label_attribute}').show()
                $('.package_packagable_id > .select2-container').css('width', '100%')
              })
            </script>
          EOT
          raw forms.html_safe
        else
          form.association associated_model,
            label_method: label_attribute,
            label: t("activerecord.models.#{associated_model}"),
            input_html: {
              class: 'use-select2',
              data: {
                placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{associated_model}.#{label_attribute}"))
              }
            }
        end
      elsif attribute_name =~ /_type$/
        associated_model = attribute_name.gsub(/_type$/, '').to_sym
        options = Dashboard.model(model_name).associated_models[associated_model]
        form.input attribute_name, collection: options[:available_models].map(&:camelize),
          input_html: {
            class: 'use-select2',
            data: {
              placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{model_name}.#{attribute_name}"))
            }
          }
      elsif needs_upload?(model_name, attribute_name) and image?(attribute_name)
        upload_image form: form, image_name: attribute_name, width: 150, height: 150
      else
        form.input attribute_name
      end
    end

    def generate_search_input form, model_name, attribute
      if attribute[:options]
        form.input "#{attribute[:name].to_s.gsub('.', '_')}_#{attribute[:term]}",
          required: false, label: false, collection: attribute[:options],
          input_html: {
            class: 'use-select2',
            data: {
              placeholder: t('carload.placeholder.select', thing: t("activerecord.attributes.#{model_name}.#{attribute[:name]}"))
            }
          }
      else
        form.input "#{attribute[:name].to_s.gsub('.', '_')}_#{attribute[:term]}",
          placeholder: t("activerecord.attributes.#{@model_name}.#{attribute[:name]}"),
          required: false, label: false
      end
    end

    def generate_show object, attribute
      case attribute
      when Symbol
        object.send attribute
      when String
        eval "object.#{attribute.gsub('.', '&.')}"
      end
    end
  end
end
