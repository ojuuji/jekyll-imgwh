require_relative 'lib/jekyll-imgwh/version'

Gem::Specification.new do |spec|
  spec.name        = Jekyll::Imgwh::NAME
  spec.version     = Jekyll::Imgwh::VERSION
  spec.summary     = "Jekyll tag for HTML <img> element with auto-generated size attributes"
  spec.description = "Jekyll tag for HTML <img> element which verifies image exists and automatically adds size attributes."
  spec.authors     = ["Mikalai Ananenka"]
  spec.email       = ["ojuuji@gmail.com"]
  spec.files       = Dir["lib/*.rb"]
  spec.homepage    = "https://github.com/ojuuji/jekyll-imgwh"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "jekyll", [">= 4.0", "< 5.0"]
  spec.add_dependency "fastimage", [">= 2.4", "< 3.0"]
end
