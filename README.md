# Uptrace Ruby exporter for OpenTelemetry

[![Build Status](https://travis-ci.org/uptrace/uptrace-ruby.svg?branch=master)](https://travis-ci.org/uptrace/uptrace-ruby)

## Installation

```bash
gem install uptrace
```

## Introduction

uptrace-ruby is an exporter for [OpenTelemetry](https://opentelemetry.io/) that
sends your traces/spans and metrics to [Uptrace.dev](https://uptrace.dev).
Briefly the process is the following:

- OpenTelemetry API is used to instrument your application with spans and
  metrics.
- OpenTelemetry SDK and this exporter send collected information to Uptrace.dev.
- Uptrace.dev uses that information to help you pinpoint failures and find
  performance bottlenecks.

## Instrumenting code

You instrument your application by wrapping potentially interesting operations
with spans. Each span has:

- an operation name;
- a start time and end time;
- a set of key/value attributes containing data about the operation;
- a set of timed events representing events, errors, logs, etc.

You create spans using a tracer:

```ruby
require 'opentelemetry'

// Create a named tracer using your repo as an identifier.
tracer = OpenTelemetry.tracer_provider.tracer('github.com/username/app-name', 'semver:1.0')
```

To create a span:

```ruby
tracer.in_span('operation-name') do |span|
  do_some_work
end
```

Internally that does roughly the following:

```ruby
// Create a span.
span = tracer.start_span('operation-name')

// Activate the span within the current context.
tracer.with_span(span) do |span|
  do_some_work
end

// Finish the span when operation is completed.
span.finish
```

To get the active span from the context:

```ruby
span = tracer.current_span
```

Once you have a span you can start adding attributes:

```ruby
span.set_attribute('enduser.id', '123')
span.set_attribute('enduser.role', 'admin')
```

or events:

```ruby
span.add_event(name: 'log', attributes: {
  'log.severity': 'error',
  'log.message': 'User not found',
  'enduser.id': '123',
})
```

To record an error use `record_error` which internally uses `add_event`. Note
that `tracer.in_span` already records resqued exceptions.

```ruby
rescue Exception => e
  span.record_error(e)
end
```
