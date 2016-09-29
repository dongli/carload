module Carload
  module DashboardHelper
    def generate_input form, model_name, attribute_name, column
      if column.type == :integer and attribute_name =~ /_id/
        associated_model = attribute_name.sub('_id', '')
        label_attribute = Dashboard.model(model_name).associated_models[associated_model.to_sym]
        form.association associated_model, label_method: label_attribute, label: t("activerecord.models.#{associated_model}")
      else
        form.input attribute_name
      end
    end

    def generate_show object, attribute
      case attribute
      when Symbol
        object.send attribute
      when String
        eval "object.#{attribute}"
      end
    end
  end
end
