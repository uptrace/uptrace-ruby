# Using OTLP exporter with Uptrace

This example shows how to configure
[OTLP](https://github.com/open-telemetry/opentelemetry-ruby/tree/main/exporter/otlp) to export
traces to Uptrace.

Install dependencies:

```shell
bundle install
```

To run this example, you need to
[create an Uptrace project](https://uptrace.dev/get/get-started.html) and pass your project DSN via
`UPTRACE_DSN` env variable:

```shell
UPTRACE_DSN="https://<token>@uptrace.dev/<project_id>" ./main.rb
```
