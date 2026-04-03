# AGENTS.md

## Project Overview

uptrace-ruby is an OpenTelemetry Ruby distribution that configures OpenTelemetry SDK to export
traces, metrics, and logs to Uptrace via OTLP/HTTP. It is a thin wrapper — not a reimplementation.

## Build & Install

```bash
bundle install
```

## Commands

Run all checks (tests + rubocop + yard):

```bash
bundle exec rake
```

Run individually:

```bash
bundle exec rake test       # minitest
bundle exec rake rubocop    # linter
bundle exec rake yard       # docs
```

## Architecture

All source lives in `lib/`:

- `uptrace.rb` — main module, `configure_opentelemetry` entry point, sets up span/metric/log
  exporters with gzip compression and batch processing
- `uptrace/client.rb` — reads DSN from param or `UPTRACE_DSN` env var, generates trace URLs
- `uptrace/dsn.rb` — parses and validates Uptrace DSN connection strings
- `uptrace/id_generator.rb` — custom trace/span ID generator using timestamp + random bytes
- `uptrace/version.rb` — gem version constant

## Tests

Tests use Minitest in `test/`. Run with `bundle exec rake test`. Currently covers DSN parsing.

## Code Conventions

- All files start with `# frozen_string_literal: true`
- Ruby >= 3.0
- RuboCop enforced with `rubocop-rake` and `rubocop-minitest` plugins
- Line length, method length, and ABC size checks are disabled
- YARD documentation with Markdown markup

## Release Process

1. Update version in `lib/uptrace/version.rb`
2. `gem build uptrace.gemspec`
3. `gem push uptrace-X.Y.Z.gem`
