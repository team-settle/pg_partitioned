require "pg_partitioned/dump_table_inherits"

module PgPartitioned
  module SchemaDumper
    include DumpTableInherits
    def tables(stream)
      super(stream)

      alter_table_inherit_statements.then do |stmts|
        break if stmts.blank?
        stream.puts ""
        stream.puts stmts.map { |stmt| "  #{stmt}"}.join("\n")
        stream.puts ""
      end
    end
  end
end
