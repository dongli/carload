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
  model :article do |spec|
    spec.default = false
    spec.attributes.permitted = [:author_id, :title, {:reader_ids=>[]}]
    spec.index_page.shows.attributes = ["author.email", :title]
    spec.index_page.searches.attributes = [{:name=>:author_id, :term=>:cont}, {:name=>:title, :term=>:cont}]
  end
  associate({:article=>:author, :choose_by=>:email})
  associate({:article=>:readers, :choose_by=>:email})
  model :item do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :product_id, :image]
    spec.index_page.shows.attributes = [:name, "product.name", :image]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:product_id, :term=>:cont}, {:name=>:image, :term=>:cont}]
  end
  associate({:item=>:product, :choose_by=>:name})
  associate({:item=>:package, :choose_by=>:name})
  model :package do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :packagable_type, :packagable_id]
    spec.index_page.shows.attributes = [:name, "packagable.name", "packagable.name"]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:packagable_type, :term=>:cont}, {:name=>:packagable_id, :term=>:cont}]
  end
  associate({:package=>:packagable, :choose_by=>:name})
  model :product do |spec|
    spec.default = false
    spec.attributes.permitted = [:name, :image, {:inventory_ids=>[]}]
    spec.index_page.shows.attributes = [:name, [:pluck, :items, :name], 'package.name', [:pluck, :inventories, :name]]
    spec.index_page.searches.attributes = [{:name=>:name, :term=>:cont}, {:name=>:image, :term=>:cont}]
  end
  associate({:product=>:items, :choose_by=>:name})
  associate({:product=>:package, :choose_by=>:name})
  associate({:product=>:inventories, :choose_by=>:name})
end
