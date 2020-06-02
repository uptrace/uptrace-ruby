# frozen_string_literal: true

require 'logger'

# Uptrace provides Uptrace exporters for OpenTelemetry.
module Uptrace
  extend self

  attr_accessor :logger

  self.logger = Logger.new(STDOUT)
end

require 'uptrace/version'
require 'uptrace/trace'
