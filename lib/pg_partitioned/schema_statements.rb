require "pg_partitioned/create_table_partition_by"
require "pg_partitioned/create_table_partition_of"

module PgPartitioned
  module SchemaStatements
    include CreateTablePartitionBy
    include CreateTablePartitionOf

    def create_table(table_name, partition_of: nil, partition_by: nil, **options)
      options[:options] = [
        partition_of ? partition_of_clause(**partition_of) : nil,
        partition_by ? partition_by_clause(**partition_by) : nil,
        options[:options]
      ].compact!.join(" ") || nil
      options[:id] = false if partition_of
      super(table_name, **options)
    end

    def table_options(table_name)
      super.to_h.merge(
        {
          partition_of: partition_of_options(table_name),
          partition_by: partition_by_options(table_name)
        }.compact!
      )
    end
  end
end
