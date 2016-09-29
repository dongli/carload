# Carload
Short description and motivation.

## Usage
- Run `rails g carload:install` to mount engine routes and add require statement.
- Run `rails g carload:dashboard` to generate `app/carload/dashboard.rb`, and edit that file for example:

```ruby
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

  model :product do |spec|
    spec.default = true
    spec.attributes.permitted = [ :name ]
    spec.index_page.shows.attributes = [ :name ]
    spec.index_page.searches.attributes = [
      { name: :name, term: :cont }
    ]
  end
  model :item do |spec|
    spec.attributes.permitted = [ :name, :product_id ]
    spec.index_page.shows.attributes = [ :name, 'product.name' ]
    spec.index_page.searches.attributes = [
      { name: :name, term: :cont },
      { name: 'product.name', term: :cont }
    ]
  end
  associate :item => :product, choose_by: :name
end
```

- Make sure you have the necessary I18n translation files, for example:

```yaml
en:
  activerecord:
    models:
      item: Item
    attributes:
      item:
        name: Name
        product:
          name: Product Name
```
```yaml
en:
  activerecord:
    models:
      product: Product
    attributes:
      product:
        name: Name
```
- Access the brand new dashboard in '<Your URL>/carload'.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'carload'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install carload
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
