module PgPartitioned
  module SchemaStatements
    def create_table(table_name, partition_by: nil, **options)
      options[:options] = partition_by_clause(**partition_by) + options[:options].to_s if partition_by
      super(table_name, **options)
    end

    def table_options(table_name)
      super.to_h.merge(table_partition_by(table_name).to_h)
    end

    private

    def partition_by_clause(strategy:, key:)
      "PARTITION BY #{strategy.to_s.upcase} (#{quote_partition_key(key)})"
    end

    def quote_partition_key(key)
      Array.wrap(key).map(&method(:quote_column_name)).join(",")
    end

    def table_partition_by(table_name)
      row = pg_partitioned_table_row(table_name)
      return unless row

      row["partclass"].each do |oid| # partclass
        default = select_value("SELECT opcdefault FROM pg_opclass WHERE oid = $1", nil, [oid])
        raise ApplicationError, "cannot handle custom opclass in partition key" unless default
      end
      row["partcollation"].each do |oid| # partcollation
        next if oid.to_i.zero?

        default = select_value("SELECT opcdefault FROM pg_opclass WHERE oid = $1", nil, [oid])
        raise ApplicationError, "cannot handle custom collation in partition key" unless default
      end

      key = row["partattrs"].map do |attnum| # partattrs
        raise ApplicationError, "cannot handle complex expressions in partition key" if attnum.to_i.zero?

        colname = select_value(
          "SELECT attname FROM pg_attribute WHERE attrelid = $1 AND attnum = $2",
          nil,
          [row["partrelid"], attnum]
        )
        raise ApplicationError, "cannot find partition key column name" unless colname

        colname
      end

      strategy = {
        "r" => :range,
        "l" => :list,
        "h" => :hash
      }[row["partstrat"]]

      { partition_by: { strategy: strategy, key: key } }
    end

    def pg_partitioned_table_row(table_name)
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
