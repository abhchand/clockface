# Clockface

[![Build Status](https://gitlab.com/abhchand/clockface/badges/master/build.svg)](https://gitlab.com/abhchand/clockface/pipelines)

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
#   default: `Rails.application.config.time_zone` (your application time zone)
app.config.clockface.time_zone = "Pacific Time (US & Canada)"

# Specify a logger for Clockface to use
#   default: `Rails.logger` (your application's logger)
app.config.clockface.logger = [Rails.logger, Logger.new(Rails.root.join("log", "clockface.log"))]

#
# (Multi Tenant Options)
#

# You can use any gem library to manage your multi tenant schemas.
# The `apartment` gem is quite popular, so the examples below reference configuration using that gem

# Tell clockface what your tenant/schema names are
#   default: []
app.config.clockface.tenant_list = %w[tenant1 tenant2]

# Tell Clockface how to get the current tenant/schema context
#   A callable proc that returns the current schema context
#   default: nil (must be specified by you)
app.config.clockface.current_tenant_proc = proc { Apartment::Tenant.current }

# Tell Clockface how to execute commands within the context of some tenant/schema
#   A callable proc that takes arguments for tenant name, another proc to
#   execute, and arguments for the proc to be executed
#   default: nil (mst be specified by you)
app.config.clockface.execute_in_tenant_proc =
  proc do |tenant_name, some_proc, proc_args|
    Apartment::Tenant.switch(tenant_name) { some_proc.call(*proc_args) }
  end
```

## Running Locally

Clone, build, install, and seed the local database with the inbuilt script.

```
git clone https://gitlab.com/abhchand/clockface
cd clockface/
```

Seed the database with the in-built script

```
bin/setup
```

Run the application with

```
bundle exec rails server
```

You can now visit the app at [http://localhost:3000/clockface](http://localhost:3000/clockface)

#### Running in Multi-Tenant mode

By default the app runs as a single tenant application. The app can also be run in multi tenant mode locally to test or develop any multi tenant features

Clone, build, install, and seed the local database with the inbuilt script.

```
git clone https://gitlab.com/abhchand/clockface
cd clockface/
```

Seed the database with the in-built script

```
bin/setup-multi-tenant
```

Run the application with

```
bundle exec rails server -b lvh.me
```


Note:
1. By default the above process seeds two tenants - "earth" and "mars" - that run on different subdomains

2. Since `localhost` does not support subdomains, we use `lvh.me` (a loopback domain) when running locally


You can now visit the "earth" tenant at [http://earth.lvh.me:3000/clockface](http://earth.lvh.me:3000/clockface)


#### Running Background Jobs


The above `rails server` commands only start the web server, which **does not start the job processing queue and run any scheduled events**.

To actually run any schedule events you'll need to start the Sidekiq server (which the dummy app uses for job scheduling) and the Clock process.

The [foreman gem](https://github.com/ddollar/foreman) can be used to easily start all processes at once (as defined in the [Procfile](./spec/dummy/Procfile))

```
bundle exec foreman start -f spec/dummy/Procfile
```

## Contributing

All are welcome to contribute.

(If you're a newbie or considered yourself inexperienced, don't hesitate to contribute. That's how you learn!)

> **NOTE**: This project only takes contributions on Gitlab. A Github mirror of this project can be found at http://github.com/abhchand/clockface

1. Open a Gitlab issue for this project [here](https://gitlab.com/abhchand/clockface/issues/new). Please include a description fo the changes / fixes you'd like to make.
2. If any project owner approves the idea, please open a new pull request agains the `master` branch.
