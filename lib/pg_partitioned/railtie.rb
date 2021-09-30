require "rails/railtie"

module PgPartitioned
  class Railtie < Rails::Railtie
    initializer "pg_partitioned.load" do
      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.send(:prepend, PgPartitioned::SchemaStatements)
      end
    end
  end
end
