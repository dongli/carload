# Carload
This is another dashboard gem for Rails (see [Rails Admin], [ActiveAdmin] and [Administrate]). Carload tries to reduce the typing when implement a dashboard, but it also allow developer to realize any page view if they like.

[Rails Admin]: https://github.com/sferik/rails_admin
[ActiveAdmin]: http://activeadmin.info/
[Administrate]: https://github.com/thoughtbot/administrate

DEMO: [https://carload-demo.herokuapp.com/carload/dashboard/](https://carload-demo.herokuapp.com/carload/dashboard/)

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/f62758b167e6d1bc1f55459ad2d53dcd.png!large)

Carload tries to handle errors gracely:

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/bf1c27a50c9987f7bfa2fb3c909d7801.png!large)

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/9afad7d8b2b747c9730db6aeb4ddd288.png!large)

Image file upload is also supported with some assumption.

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/d9fc7b42fdcd1a7700faa26a47e037c1.png!large)

## Usage
- Run `rails g carload:install` to mount engine routes, add require statement, initializer, and `Dashboard` class file.

You can edit the initializer `config/initializers/carload.rb` for example:

```ruby
Carload.setup do |config|
  # Specify which authentication solution is used. Currently, we only support Devise.
  config.auth_solution = :devise

  # Set the actions used to discern user's permission to access dashboard.
  #
  #   config.dashboard.permits_user.<method> = '...'
  #
  # There are four access methods can be configured:
  #
  #   index, new, edit, destroy
  #
  # Also you can use a special method 'all' to set the default permission.
  # The permission can also be array, the relation among them is OR.
  # By doing this, you have full control on the access permission.
  # TODO: Set the permissions for each data table.
  config.dashboard.permits_user.all = 'role.admin?'
end
```

Edit `app/carload/dashboard.rb` to adapt for your needs, for example:

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

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
