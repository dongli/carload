# Dashboard class is used to tell Carload what models are needed to administrated,
# which attributes are shown, etc.

class Dashboard < Carload::Dashboard
  # There two DSL block types:
  #
  #   model :<model_name> do |spec|
  #     # Whether model should be displayed when URL does not specify one
  #     spec.default = <true_or_false>
  #     # List of attributes that can be edited
  #     spec.attributes.permitted = [...]
  #     # List of attributes that will be shown on index page
  #     spec.index_page.shows.attributes = [...]
  #     # List of attributes with search terms that can be searched on index page (using Ransack gem)
  #     spec.index_page.searches.attributes = [ { name: ..., term: ...}, ... ]
  #   end
  #
  #   associate :<model_name_a> => :<model_name_b>, choose_by: :<attribute_in_model_b>

  model :product do |spec|
    spec.default = true
    spec.attributes.permitted = [ :name, :image ]
    spec.index_page.shows.attributes = [ :name ]
    spec.index_page.searches.attributes = [
      { name: :name, term: :cont }
    ]
  end
  model :item do |spec|
    spec.attributes.permitted = [ :name, :image, :product_id ]
    spec.index_page.shows.attributes = [ :name, 'product.name' ]
    spec.index_page.searches.attributes = [
      { name: :name, term: :cont },
      { name: 'product.name', term: :cont }
    ]
  end
  associate :item => :product, choose_by: :name
end
