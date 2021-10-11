require "active_support/concern"

module PgPartitioned
  module Partitionable
    extend ActiveSupport::Concern

    class_methods do
      def create_partition(name, **for_values)
        connection.create_table("#{table_name}_#{name}",
                                partition_of: { table: table_name, for_values: for_values })
      end
    end
  end
end
