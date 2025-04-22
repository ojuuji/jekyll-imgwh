# frozen_string_literal: true

require_relative "lib/jekyll-imgwh/version"

Gem::Specification.new do |spec|
  spec.name        = Jekyll::Imgwh::NAME
  spec.version     = Jekyll::Imgwh::VERSION
  spec.summary     = "Jekyll tag for HTML <img> element with auto filled size attributes"
  spec.description = <<~DESCRIPTION
    Jekyll tag for HTML <img> element which verifies that image exists and automatically fills width and height attributes.
  DESCRIPTION
  spec.authors     = ["Mikalai Ananenka"]
  spec.email       = ["ojuuji@gmail.com"]
  spec.files       = Dir["lib/**/*"]
  spec.homepage    = "https://github.com/ojuuji/jekyll-imgwh"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.add_runtime_dependency "fastimage", "~> 2.4"
  spec.add_runtime_dependency "jekyll", "~> 4.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.14.0"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0"
  spec.add_development_dependency "ruby-lsp", "~> 0.9"
end
