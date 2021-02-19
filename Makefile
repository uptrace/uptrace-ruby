publish:
	gem build uptrace.gemspec
	bundle install
	gem push uptrace-0.2.0.gem
