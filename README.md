# image-al2023-ruby

An simple Dockerfile to build ruby from source on AL2023.

## make help

Available targets:
  build  - Build the Docker image (default)
  run    - Run the Docker container interactively
  clean  - Remove the Docker image
  help   - Show this help message

Build arguments:
  RUBY_VERSION     - Ruby version to build (default: 3.4.5)
  RUBY_MAJOR       - Ruby major version (default: 3.4)
  RUBYGEMS_VERSION - RubyGems version to install (default: 3.7.2)
  BUNDLER_VERSION  - Bundler version to install (default: 2.7.2)
  RUBY_PREFIX      - Installation directory (default: /opt/ruby/3.4)
  GEM_SOURCE       - RubyGems source URL (default: https://rubygems.org)

Examples:
  make                                    # Build with default Ruby 3.4.5 at /opt/ruby/3.4
  make RUBY_VERSION=3.3.6 RUBY_MAJOR=3.3  # Build with Ruby 3.3.6 at /opt/ruby/3.3
  make RUBY_PREFIX=/usr/local             # Install Ruby to /usr/local
