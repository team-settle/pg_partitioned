require "delegate"

module PgPartitioned
  module CreateTablePartitionBy
    private

    def partition_by_clause(strategy:, key:)
      "PARTITION BY #{strategy.to_s.upcase} (#{quote_partition_key(key)})"
    end

    def partition_by_options(table_name)
      data = pg_partitioned_table_data(table_name)
      return unless data

      data["partclass"].each do |oid| # partclass
        default = select_value("SELECT opcdefault FROM pg_opclass WHERE oid = $1", nil, [oid])
        raise NotYetImplementedError, "cannot handle custom opclass in partition key" unless default
      end
      data["partcollation"].each do |oid| # partcollation
        next if oid.to_i.zero?

        default = select_value("SELECT opcdefault FROM pg_opclass WHERE oid = $1", nil, [oid])
        raise NotYetImplementedError, "cannot handle custom collation in partition key" unless default
      end

      key = data["partattrs"].map do |attnum| # partattrs
        raise NotYetImplementedError, "cannot handle complex expressions in partition key" if attnum.to_i.zero?

        colname = select_value(
          "SELECT attname FROM pg_attribute WHERE attrelid = $1 AND attnum = $2",
          nil,
          [data["partrelid"], attnum]
        )
        raise NotYetImplementedError, "cannot find partition key column name" unless colname

        colname
      end

      strategy = {
        "r" => :range,
        "l" => :list,
        "h" => :hash
      }[data["partstrat"]]

      { strategy: strategy, key: key }
    end

    def quote_partition_key(key)
      Array.wrap(key).map(&method(:quote_column_name)).join(",")
    end

    def pg_partitioned_table_data(table_name)
      scope = quoted_scope(table_name, type: "BASE TABLE")
      return unless scope[:name]

      rows = select_all(<<~SQL).cast_values
        SELECT partrelid, partstrat, partattrs::int2[], partclass::oid[], partcollation::oid[]
        FROM pg_partitioned_table
        WHERE partrelid = #{scope[:name]}::regclass
      SQL
      return unless rows.present?

      %w[partrelid partstrat partattrs partclass partcollation] \
        .each_with_index.map { |x, i| [x, rows[0][i]] }.to_h
    end
  end
end
