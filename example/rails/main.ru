# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'bundler/setup'
require 'action_controller/railtie'
require 'opentelemetry-instrumentation-rails'
require 'uptrace'

# TraceRequestApp is a minimal Rails application inspired by the Rails
# bug report template for action controller.
# The configuration is compatible with Rails 6.0
class TraceRequestApp < Rails::Application
  config.root = __dir__
  config.hosts << 'example.org'
  secrets.secret_key_base = 'secret_key_base'
  config.eager_load = false
  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger
end

upclient = Uptrace::Client.new do |c|
  # copy your project DSN here or use UPTRACE_DSN env var
  # c.dsn = ''
end

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Rails'

  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  c.add_span_processor(upclient.span_processor)
end

Rails.application.initialize!

run Rails.application
