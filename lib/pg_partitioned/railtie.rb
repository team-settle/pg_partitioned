require "rails/railtie"

module PgPartitioned
  class Railtie < Rails::Railtie
    initializer "pg_partitioned.load" do
      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.prepend(PgPartitioned::SchemaStatements)
        ActiveRecord::SchemaDumper.prepend(PgPartitioned::SchemaDumper)
      end
    end
  end
end
