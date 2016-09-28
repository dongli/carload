# Carload
Short description and motivation.

## Usage
- Add `DashboardController` in your application, for example:
```ruby
class DashboardController < ApplicationController
  DEFAULT_MODEL = :product
  MODELS = [ :product, :item ]
  PERMITTED_ATTRIBUTES = {
    product: [ :name ],
    item: [ :name, :product_id ]
  }.freeze
  SHOW_ATTRIBUTES_ON_INDEX = {
    product: [ :name ],
    item: [ :name, 'product.name' ]
  }
  ASSOCIATIONS = {
    item: { product: :name }
  }
  SEARCH_ATTRIBUTES_ON_INDEX = {
    product: { name: :cont },
    item: { name: :cont }
  }
end
```
- Mount engine route in `config/routes.rb`:
```ruby
mount Carload::Engine => '/carload'
```
- Add necessary I18n translation files, for example:
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

****
**I am trying to write a beautiful DSL for DashboardController if you like.**
****

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
