Gem::Specification.new do |spec|
  spec.name        = "jekyll-imgwh"
  spec.version     = "0.3"
  spec.summary     = "Jekyll tag for HTML <img> element with auto-generated size attributes"
  spec.description = "Jekyll tag for HTML <img> element which verifies image exists and automatically adds size attributes."
  spec.authors     = ["Mikalai Ananenka"]
  spec.email       = ["ojuuji@gmail.com"]
  spec.files       = ["lib/jekyll-imgwh.rb"]
  spec.homepage    = "https://github.com/ojuuji/jekyll-imgwh"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "jekyll", [">= 4.0", "< 5.0"]
  spec.add_dependency "fastimage", [">= 2.4", "< 3.0"]
end
