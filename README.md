# Uptrace Ruby exporter for OpenTelemetry

![build workflow](https://github.com/uptrace/uptrace-ruby/actions/workflows/build.yml/badge.svg)
[![Documentation](https://img.shields.io/badge/uptrace-documentation-informational)](https://uptrace.dev/get/opentelemetry-ruby.html)
[![Chat](https://img.shields.io/badge/-telegram-red?color=white&logo=telegram&logoColor=black)](https://t.me/uptrace)

<a href="https://uptrace.dev/get/opentelemetry-ruby.html">
  <img src="https://uptrace.dev/get/devicon/ruby-original.svg" height="200px" />
</a>

## Introduction

uptrace-ruby is an OpenTelemery distribution configured to export
[traces](https://uptrace.dev/opentelemetry/distributed-tracing.html) to Uptrace.

## Quickstart

Install uptrace-ruby:

```bash
gem install uptrace
```

Run the [basic example](example/basic) below using the DSN from the Uptrace project settings page.

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Configure OpenTelemetry with sensible defaults.
# Copy your project DSN here or use UPTRACE_DSN env var.
Uptrace.configure_opentelemetry(dsn: '') do |c|
  # c is OpenTelemetry::SDK::Configurator
  c.service_name = 'myservice'
  c.service_version = '1.0.0'
end

# Create a tracer. Usually, tracer is a global variable.
tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

# Create a root span (a trace) to measure some operation.
tracer.in_span('main-operation') do |main|
  tracer.in_span('child1-of-main') do |child1|
    child1.set_attribute('key1', 'value1')
    child1.record_exception(ArgumentError.new('error1'))
  end

  tracer.in_span('child2-of-main') do |child2|
    child2.set_attribute('key2', '24')
    child2.set_attribute('key3', 123.456)
  end

  puts("trace URL: #{Uptrace.trace_url(main)}")
end

# Send buffered spans and free resources.
OpenTelemetry.tracer_provider.shutdown
```

## Links

- [Examples](example)
- [Documentation](https://uptrace.dev/get/opentelemetry-ruby.html)
- [OpenTelemetry Instrumentations](https://uptrace.dev/opentelemetry/instrumentations/?lang=ruby)
- [OpenTelemetry Rails](https://uptrace.dev/opentelemetry/instrumentations/ruby-rails.html)
- [OpenTelemetry Sinatra](https://uptrace.dev/opentelemetry/instrumentations/ruby-sinatra.html)
