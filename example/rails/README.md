# Rails

## Example

This example demonstrates how to instrument Rails application using OpenTelemetry and configure
OpenTelemetry to export data to Uptrace.

Install dependencies:

```shell
bundle install
```

Start the server and open [http://localhost:9292/](http://localhost:9292/):

```shell
UPTRACE_DSN="https://<token>@api.uptrace.dev/<project_id>" rackup main.ru
```

## Documentation

See
[opentelemetry-instrumentation-rails](https://github.com/open-telemetry/opentelemetry-ruby/tree/main/instrumentation/rails).
