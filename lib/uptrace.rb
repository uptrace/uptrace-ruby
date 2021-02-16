# frozen_string_literal: true

require 'logger'

# Uptrace provides Uptrace exporters for OpenTelemetry.
module Uptrace
  extend self

  attr_accessor :logger

  self.logger = Logger.new($stdout)
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/trace'
