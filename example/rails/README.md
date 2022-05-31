# Instrumenting Rails with OpenTelemetry example

## Example

This example demonstrates how to instrument Rails application using OpenTelemetry and configure
OpenTelemetry to export data to Uptrace.

Install dependencies:

```shell
bundle install
```

Start the server:

```shell
UPTRACE_DSN="https://<token>@uptrace.dev/<project_id>" rackup main.ru
```

Then open [http://localhost:9292/](http://localhost:9292/)

## Documentation

See
[Instrumenting Rails with OpenTelemetry](https://opentelemetry.uptrace.dev/instrumentations/ruby-rails.html)
for details.
