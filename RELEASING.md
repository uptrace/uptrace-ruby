# Releasing

This guide explains how to release a new version of the uptrace-ruby gem to
RubyGems.

## Managing Dependencies

### Checking for outdated dependencies

To view outdated dependencies:

```shell
bundle outdated
```

### Updating dependencies

Edit the `Gemfile` to update dependency versions, then update the
`Gemfile.lock`:

```shell
bundle update
```

### Installing dependencies

To install all dependencies:

```shell
bundle install
```

## Running Tests

Before releasing, ensure all tests pass:

```shell
rake test
```

## Running linter

To run linter:

```shell
bundle exec rake
```

To auto-correct issues:

```shell
bundle exec rubocop -A
```

## Publishing a Release

1. **Update the version**: Bump the version number in `lib/uptrace/version.rb`

2. **Build and publish the gem**:

   ```shell
   gem build uptrace.gemspec
   bundle install
   gem push uptrace-X.Y.Z.gem
   ```

   Replace `X.Y.Z` with the actual version number you specified in step 1.

**Note**: Make sure you have the necessary permissions to push to the uptrace
gem on RubyGems before attempting to publish.
