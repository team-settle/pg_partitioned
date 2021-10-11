require "delegate"

module PgPartitioned
  module CreateTablePartitionOf
    private

    def partition_of_clause(table:, for_values: nil)
      if for_values
        "PARTITION OF #{table} FOR VALUES #{partition_spec(**for_values)}"
      else
        "PARTITION OF #{table} DEFAULT"
      end
    end

    def partition_of_options(table_name)
      data = pg_partition_data(table_name)
      return unless data

      raise NotYetImplementedError, "cannot handle partitions"
    end

    def partition_spec(**options)
      if options.key?(:list)
        partition_spec_list(**options)
      elsif options.key?(:from) || options.key?(:to)
        partition_spec_range(**options)
      elsif options.key?(:modulus) || options.key?(:remainder)
        partition_spec_hash(**options)
      else
        raise ArgumentError, "no relevant arguments given"
      end
    end

    def partition_spec_list(list:)
      "IN (#{quote_values(list)})"
    end

    def partition_spec_range(from:, to:)
      "FROM (#{quote_values(from)}) TO (#{quote_values(to)})"
    end

    def partition_spec_hash(modulus:, remainder:)
      "WITH (MODULUS #{modulus.to_i}, REMAINDER #{remainder.to_i})"
    end

    def quote_values(values)
      Array.wrap(values).map(&method(:quote)).join(",")
    end

    def pg_partition_data(table_name)
      scope = quoted_scope(table_name, type: "BASE TABLE")
      return unless scope[:name]

      rows = select_all(<<~SQL).cast_values
        SELECT inhrelid, partrelid, partstrat, partattrs::int2[], partclass::oid[], partcollation::oid[]
        FROM pg_partitioned_table INNER JOIN pg_inherits ON partrelid = inhparent
        WHERE inhrelid = #{scope[:name]}::regclass
      SQL
      return unless rows.present?

      %w[inhrelid partrelid partstrat partattrs partclass partcollation] \
        .each_with_index.map { |x, i| [x, rows[0][i]] }.to_h
    end
  end
end
