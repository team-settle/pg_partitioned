module PgPartitioned
  module DumpTableInherits
    private

    def alter_table_inherit_statements
      rows = pg_inherits_rows
      return unless rows.present?

      rows.map do |row|
        "execute 'ALTER TABLE #{@connection.quote_table_name(row['inhrelid'])} " \
          "INHERIT #{@connection.quote_table_name(row['inhparent'])}'"
      end.sort
    end

    def pg_inherits_rows
      rows = @connection.select_all(<<~SQL).cast_values
        SELECT inhrelid::regclass::text, inhparent::regclass::text
        FROM pg_inherits
        LEFT OUTER JOIN pg_partitioned_table ON partrelid = inhparent
        LEFT OUTER JOIN pg_index ON indexrelid = inhrelid
        WHERE partrelid IS NULL
        AND indexrelid IS NULL;
      SQL

      rows.map do |row|
        %w[inhrelid inhparent] \
          .each_with_index.map { |x, i| [x, rows[0][i]] }.to_h
      end
    end
  end
end
