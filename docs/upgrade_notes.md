## Where I left off

  bundle exec rspec spec/services/transparency_reporting_service_spec.rb

Specs are failing because environment variables are not loading

## Getting from Ruby 2.8 to 3.2

    gem install ffi -v '1.9.25' -- --with-cflags="-Wno-error=implicit-function-declaration -Wno-error=incompatible-function-pointer-types"

    gem install pg -v '1.1.3' -- --with-cflags="-Wno-error=implicit-function-declaration -Wno-error=incompatible-function-pointer-types"

    gem install jaro_winkler -v '1.5.2' -- --with-cflags="-Wno-error=implicit-function-declaration -Wno-error=incompatible-function-pointer-types"
