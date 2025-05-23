# frozen_string_literal: true

require "jekyll/imgwh/tag"

module Jekyll
  module Imgwh
    def imgwh(src)
      image_size(src, @context)
    end

    Liquid::Template.register_filter(self)

    # Include after register_filter so they do not leak to Liquid yet are accessible within imgwh()
    extend self
    include Helpers

    Liquid::Template.register_tag(name, Tag)
  end
end
