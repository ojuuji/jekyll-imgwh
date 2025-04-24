# frozen_string_literal: true

require "jekyll/imgwh/tag"

module Jekyll
  module Imgwh
    Liquid::Template.register_tag "imgwh", Tag

    def imgwh(src)
      image_size(src, @context)
    end

    Liquid::Template.register_filter(self)

    # Include after register_filter so they do not leak to Liquid yet are accessible within imgwh()
    include Helpers
  end
end
