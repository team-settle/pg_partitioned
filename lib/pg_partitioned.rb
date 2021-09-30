# frozen_string_literal: true

require_relative "pg_partitioned/version"
require "pg_partitioned/railtie"
require "pg_partitioned/schema_dumper"
require "pg_partitioned/schema_statements"

module PgPartitioned
  class Error < StandardError; end
  # Your code goes here...
end
