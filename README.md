# StaticModel

![CI](https://github.com/olegsta/static_model/actions/workflows/ci.yml/badge.svg)

This gem helps to use all power ActiveRecord without creating database table.

Sometime we need to create a model with defined records and for using all ActiveRecord power we need to put this data into database, for example, with rails way we need:

```ruby
class Department < ActiveRecord::Base

end

class User < ActiveRecord::Base
  belong_to :department
end

db/migrate

class CreateHotspots < ActiveRecord::Migration[4.2]
  def change
    create_table :departments do |t|
      t.string :key
      t.string :name
      t.text :order
    end
  end
end

than fill db with rake task:
Department.create(...)
```

With this gem, we can do the same without creating database table, only need to define data via self.data
```ruby

class Department < StaticModel::Base
  attr_reader :key, :name, :order
  self.primary_key = "key"

  self.data = [
    new(
        key: 'consumer_technology', name: 'Consumer & Technology', order: 1
        ),
    new(
        key: 'research_informatics', name: 'Research & Informatics', order: 2
        ),
    new(
        key: 'health', name: 'Business Solutions & Partnerships', order: 3
        ),
    new(
        key: 'client_services', name: 'Program Management', order: 4
        ),
    new(
        key: 'internal_services', name: 'Administration', order: 5
        ),
     ]

  def users
    Department
      .where(admin_privileges: { department_id: key })
      .order(:last_name, :first_name)
    end
end

class User
  include StaticModel::ActiveRecordExtensions

  belongs_to_static_model :department, class_name: "Department", foreign_key: "key_id"
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'static_model', git: 'https://github.com/olegsta/static_model'
```

And then execute:

```ruby
  $ bundle install
```

Or install it yourself as:

```ruby
  $ gem install static_model
```

## Usage

For Static Model need to add 

```ruby
  Model < StaticModel::Base 
```

and then we can use such methods:
```ruby
  all, where, find_by, find_by!, find, pluck
```

For Ability of using assosiations `belongs_to_static_model` we need to add 
```ruby
  class User < ApplicationRecord
    include StaticModel::ActiveRecordExtensions 
  end
```
and then receive our model assosiation
```ruby
  User.first.department
```

After this, we have such methods:
```ruby
  User.first.department
  Department.all =>
  Department.first.name =>
  Department.where(order: 5) =>
  Department.find_by(key: 'client_services') =>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/static_model. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/static_model/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StaticModel project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/static_model/blob/master/CODE_OF_CONDUCT.md).
