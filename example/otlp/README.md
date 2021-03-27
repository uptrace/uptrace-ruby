# Using OTLP exporter with Uptrace

This example shows how to configure
[OTLP](https://github.com/open-telemetry/opentelemetry-ruby/tree/main/exporter/otlp) to export
traces to Uptrace.

Install dependencies:

```shell
bundle install
```

Run:

```shell
UPTRACE_DSN="https://<token>@api.uptrace.dev/<project_id>" ./main.rb
```
