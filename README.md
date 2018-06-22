# Clockface <img src="https://gitlab.com/abhchand/clockface/raw/master/meta/clockface.png" alt="Clockface" style="height: 36px;">

[![Build Status](https://travis-ci.org/abhchand/clockface.svg?branch=master)](https://travis-ci.org/abhchand/clockface)

A lightweight UI for the [Clockwork gem](https://github.com/Rykian/clockwork) to easily schedule and manage background jobs. It's built as a [Rails Engine](http://guides.rubyonrails.org/engines.html) to extend the functionality of your Rails Application

![Clockface](https://gitlab.com/abhchand/clockface/raw/master/meta/screenshot.png)

Clockface serves as a **complete UI wrapper** on top of clockwork -

- It includes and configures clockwork directly so you only have to worry about configuring one thing - Clockface
- It doesn't add any new functionality on top of clockwork. It simply adds a UI for management and execution

##### Multi Tenancy

Clockface also supports schema-based multi-tenancy!

See the [Multi Tenancy section](#multi_tenancy) below.

### Have a Question?

Find us on StackOverflow! Just [ask a question](https://stackoverflow.com/questions/ask) and include the [`clockface`](https://stackoverflow.com/questions/tagged/clockface) tag.


## Quickstart (In 4 Easy Steps)

#### A. Add Clockface

Add the Clockface gem. Remove the `clockwork` gem if you're already using it - Clockface takes care of including and invoking it.

```ruby
gem "clockface"
```

```diff
- gem "clockwork"
```

Clockface uses DB tables to store your scheduled events, so you'll need to create them in your application

```ruby
rake clockface:install:migrations
rake db:migrate
```

#### B. Configure Clockface

Mount the Clockface engine in your `routes.rb` files

```ruby
mount Clockface::Engine => "/clockface"
```

Create an initializer under `config/initializers/clockface.rb` and configure Clockface options. For more options - including multi tenancy configuration options - see [Configuration Options](#configuration_options) below

```ruby
Clockface::Engine.configure do |app|
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"
end
```

#### C. Define `clock.rb`

Create a `clock.rb` file in your application's root, or replace your existing `clock.rb` file if you're already using the `clockwork` gem

```ruby
# /clock.rb
require_relative "./config/boot"
require_relative "./config/environment"

require "clockface"

Clockface.sync_database_events(every: 10.seconds) do |event|
  # An Event is a scheduled instance of a particular Task.
  #
  # You will define new Tasks and Events in the UI (see further below), and
  # the `Event` DB record will be yielded to your application here for
  # execution.
  #
  # You're free to do anything you like with this yielded record. Specifically,
  # the `command` field exists to store any relevant job execution information.
  #
  # For example: we might use the `command` field to store the class of the
  # job we wish to schedule with Sidekiq.
  #
  #  > command: "{\"class\":\"MyHardWorker\"}"

  klass = JSON.parse(event.command)["class"]
  klass.constantize.perform_async
end
```

#### D. Create New Tasks and Schedule Events!




## <a name="configuration_options"></a>Configuration Options

```ruby
# Specify a timezone for display purposes. Because humans don't work in UTC.
#   values: Any valid timezone supported by ActiveSupport (see `ActiveSupport::TimeZone::MAPPING.keys`)
#   default: `Rails.application.config.time_zone` (your application time zone)
#
# e.g.
app.config.clockface.time_zone = "Pacific Time (US & Canada)"

# Specify a logger for Clockface to use
#   values: A single logger or an array of multiple loggers
#   default: `Rails.logger` (your application's logger)
#
# e.g.
app.config.clockface.logger = [Rails.logger, Logger.new(Rails.root.join("log", "clockface.log"))]

#
# (Multi Tenant Options)
#

# You can use any gem library to manage your multi tenant schemas. The `apartment` gem is quite popular, so the examples below reference configuration using that gem

# Tell clockface what your tenant/schema names are
#   values: An array of strings
#   default: []
#
# e.g.
app.config.clockface.tenant_list = %w[tenant1 tenant2]

# Tell Clockface how to get the current tenant/schema context
#   values: A callable proc that returns the current schema context
#   default: nil (must be specified by you)
#
# e.g. (if using the `apartment` gem)
app.config.clockface.current_tenant_proc = proc { Apartment::Tenant.current }

# Tell Clockface how to execute commands within the context of some tenant/schema
#   values: A callable proc that takes arguments for tenant name, another proc to execute,
#         and arguments for the proc to be executed
#   default: nil (mst be specified by you)
#
# e.g.
app.config.clockface.execute_in_tenant_proc =
  proc do |tenant_name, some_proc, proc_args|
    Apartment::Tenant.switch(tenant_name) { some_proc.call(*proc_args) }
  end
```
