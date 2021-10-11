# frozen_string_literal: true

require_relative "pg_partitioned/version"
require "pg_partitioned/railtie"
require "pg_partitioned/schema_statements"
require "pg_partitioned/partitionable"

module PgPartitioned
  class NotYetImplementedError < StandardError; end
end
