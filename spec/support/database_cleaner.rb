RSpec.configure do |config|
  config.before(:suite) do
    # We need to TRUNCATE tables to clear them. Transactions would be
    # preferable, but they don't play nice with Capybara's web server unless
    # we force all ActiveRecord connections to use the same connection
    #   See: http://bit.ly/2pW2cPx
    #
    #
    # Clockface originally used the popular `database_cleaner` gem to implement
    # this truncation, but the current verions has some issues working with
    # multi-tenant databases when using the truncation strategy.
    #   See: https://github.com/DatabaseCleaner/database_cleaner/issues/515
    #
    # Ultimately, all we need to do is TRUNCATE a handful of tables before
    # each spec, and we can just write that oursleve instead of introducing
    # another dependency and having to put up with its quirks.

    # Get a list of all tables across all schemas
    $clockface_table_list = []

    (["public"] + TENANTS).each do |tenant|
      ActiveRecord::Base.connection.tables.each do |table|
        if !%w(schema_migrations ar_internal_metadata).include?(table)
          $clockface_table_list <<
            ActiveRecord::Base.connection.quote_table_name(
              [tenant, table].join(".")
            )
        end
      end
    end
  end

  config.before(:each) do
    ActiveRecord::Base.connection.execute(
      <<-SQL
        TRUNCATE TABLE #{$clockface_table_list.join(", ")}
        RESTART IDENTITY CASCADE;
      SQL
    )
  end
end
