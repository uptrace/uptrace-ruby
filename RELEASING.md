# Releasing

This guide explains how to release a new version of the uptrace-ruby gem to
RubyGems.

## Install Ruby

On Ubuntu, install Ruby with rbenv:

```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv init
rbenv install -l
rbenv install 3.4.8
rbenv global 3.4.8
```

## Managing Dependencies

### Checking for outdated dependencies

To view outdated dependencies:

```shell
bundle outdated
```

### Updating dependencies

Edit `uptrace.gemspec` to update dependency versions, then update the
`Gemfile.lock`:

```shell
bundle update
```

Also refresh the lockfiles of the examples, which use the local gem:

```shell
for d in example/*/; do (cd "$d" && bundle update); done
```

### Installing dependencies

To install all dependencies:

```shell
bundle install
```

## Running Tests

Before releasing, ensure all tests pass:

```shell
bundle exec rake test
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
   gem push uptrace-X.Y.Z.gem --otp CODE
   ```

   Replace `X.Y.Z` with the actual version number you specified in step 1 and
   `CODE` with your current RubyGems MFA code (MFA is required to push).

3. **Tag the release**:

   ```shell
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

**Note**: Make sure you have the necessary permissions to push to the uptrace
gem on RubyGems before attempting to publish.
