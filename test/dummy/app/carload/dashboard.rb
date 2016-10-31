# Dashboard class is used to tell Carload what models are needed to administrated,
# which attributes are shown, etc.

class Dashboard < Carload::Dashboard
  # There are two DSL block types:
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

  model :user do |spec|
    spec.default = true
    spec.attributes.permitted = [:email, :role]
    spec.index_page.shows.attributes = [:email, :role]
    spec.index_page.searches.attributes = [{:name=>:email, :term=>:cont}, {:name=>:role, :term=>:cont}]
  end
  model :item do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :product_id, :image]
    spec.index_page.shows.attributes = [:name, :image, "product.name", "package.name"]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:product_id, :term=>:cont}, {:name=>:image, :term=>:cont}]
  end
  associate({:item=>:product, :choose_by=>:name})
  associate({:item=>:package, :choose_by=>:name})
  model :product do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :image, {:item_ids=>[]}, {:inventory_ids=>[]}]
    spec.index_page.shows.attributes = [:name, :image, [:pluck, :items, :name], "package.name", [:pluck, :inventories, :name]]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:image, :term=>:cont}]
  end
  associate({:product=>:item, :choose_by=>:name})
  associate({:product=>:package, :choose_by=>:name})
  associate({:product=>:inventory, :choose_by=>:name})
  model :package do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :packagable_type, :packagable_id]
    spec.index_page.shows.attributes = [:name, :packagable_type, "packagable.name"]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:packagable_type, :term=>:cont}, {:name=>:packagable_id, :term=>:cont}]
  end
  associate({:package=>:packagable, :choose_by=>:name})
  model :inventory do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, {:product_ids=>[]}]
    spec.index_page.shows.attributes = [:name, [:pluck, :products, :name]]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}]
  end
  associate({:inventory=>:product, :choose_by=>:name})
end
