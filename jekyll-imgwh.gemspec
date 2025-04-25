# frozen_string_literal: true

require_relative "lib/jekyll/imgwh/version"

Gem::Specification.new do |spec|
  spec.name     = Jekyll::Imgwh::NAME
  spec.version  = Jekyll::Imgwh::VERSION
  spec.authors  = ["Mikalai Ananenka"]
  spec.email    = ["ojuuji@gmail.com"]
  spec.homepage = "https://github.com/ojuuji/jekyll-imgwh"
  spec.license  = "MIT"
  spec.summary  = "A tag for <img> element with some automation, and a filter returning image size."
  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues",
  }

  spec.files            = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md"]

  spec.required_ruby_version = ">= 2.7"

  spec.add_runtime_dependency "fastimage", "~> 2.4"
  spec.add_runtime_dependency "jekyll", "~> 4.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.14.0"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0"
  spec.add_development_dependency "ruby-lsp", "~> 0.9"
end
