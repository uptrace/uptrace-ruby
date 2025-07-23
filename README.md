# OpenTelemetry Ruby distro for Uptrace

![build workflow](https://github.com/uptrace/uptrace-ruby/actions/workflows/build.yml/badge.svg)
[![Documentation](https://img.shields.io/badge/uptrace-documentation-informational)](https://uptrace.dev/get/opentelemetry-ruby)
[![Chat](https://img.shields.io/badge/-telegram-red?color=white&logo=telegram&logoColor=black)](https://t.me/uptrace)

<a href="https://uptrace.dev/get/opentelemetry-ruby">
  <img src="https://uptrace.dev/devicon/ruby-original.svg" height="200px" />
</a>

## Introduction

`uptrace-ruby` is a preconfigured [OpenTelemetry](https://opentelemetry.io)
distribution for Ruby that exports **traces, logs, and metrics** to
[Uptrace](https://uptrace.dev). It builds on top of
[opentelemetry-ruby](https://github.com/open-telemetry/opentelemetry-ruby) and
makes connecting your application to Uptrace fast and easy.

## Quickstart

Install uptrace-ruby:

```bash
gem install uptrace
```

Run the [traces example](example/traces) below using the DSN from the Uptrace
project settings page.

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Configure OpenTelemetry with sensible defaults.
# DSN can be set via UPTRACE_DSN environment variable.
# Example: export UPTRACE_DSN="https://<project_secret>@uptrace.dev?grpc=4317"
Uptrace.configure_opentelemetry(dsn: '') do |c|
  # c is an instance of OpenTelemetry::SDK::Configurator

  # Configure service metadata (helps identify this service in Uptrace).
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  # Add environment information
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'deployment.environment.name' => ENV.fetch('RACK_ENV', 'development')
  )
end

# Ensure spans are flushed even if the program exits unexpectedly.
at_exit { OpenTelemetry.tracer_provider.shutdown }

# Register a tracer (usually stored globally).
TRACER = OpenTelemetry.tracer_provider.tracer('my_app', '0.1.0')

# Example trace with nested spans.
TRACER.in_span('main-operation', kind: :server) do |main_span|
  # Simulate an HTTP request span.
  TRACER.in_span('GET /posts/:id', kind: :client) do |http_span|
    http_span.set_attribute('http.method', 'GET')
    http_span.set_attribute('http.route', '/posts/:id')
    http_span.set_attribute('http.url', 'http://localhost:8080/posts/123')
    http_span.set_attribute('http.status_code', 200)
    http_span.record_exception(ArgumentError.new('Invalid parameter'))
  end

  # Simulate a database query span.
  TRACER.in_span('SELECT posts', kind: :client) do |db_span|
    db_span.set_attribute('db.system', 'mysql')
    db_span.set_attribute('db.statement', 'SELECT * FROM posts LIMIT 100')
  end

  # Print the trace URL (clickable in console).
  puts "Trace URL: #{Uptrace.trace_url(main_span)}"
end
```

Additional examples are available for [logs](example/logs) and
[metrics](example/metrics).

## Links

- [Examples](example)
- [Documentation](https://uptrace.dev/get/opentelemetry-ruby)
- [OpenTelemetry Rails](https://uptrace.dev/guides/opentelemetry-rails)
- [OpenTelemetry Sinatra](https://uptrace.dev/guides/opentelemetry-sinatra)
