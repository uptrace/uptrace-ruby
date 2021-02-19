#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

client = Uptrace::Client.new do |c|
  # copy your project DSN here or use UPTRACE_DSN env var
  # c.dsn = ''
  c.service_name = 'myservice'
  c.service_version = '1.0.0'
end

tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

tracer.in_span('main') do |span|
  tracer.in_span('child1') do |child1|
    child1.set_attribute('key1', 'value1')
    child1.record_exception(ArgumentError.new('error1'))
  end

  tracer.in_span('child2') do |child2|
    child2.set_attribute('key2', '24')
    child2.set_attribute('key3', 123.456)
  end

  puts("trace URL: #{client.trace_url(span)}")
end

client.shutdown
