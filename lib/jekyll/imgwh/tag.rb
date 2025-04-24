# frozen_string_literal: true

require "jekyll/imgwh/helpers"

module Jekyll
  module Imgwh
    class Tag < Liquid::Tag
      include Helpers

      def initialize(tag_name, content, tokens)
        super

        @content = content.strip

        if (m = @content.match(%r/^(["'])((?:\1\1|(?!\1).)+)\1(?:\s+(.+))?$/))
          @quote, @src, @rest = m.captures
          @src = @src.gsub("#{@quote}#{@quote}", @quote)

        elsif (m = @content.match(%r/^(?!["'])((?:(?!\{\{)\S|\{\{.+?\}\})+)(?:\s+(.+))?$/))
          @quote = ""
          @src, @rest = m.captures

        else
          raise SyntaxError, "#{NAME}: invalid #{tag_name} tag: '#{@content}'"
        end
      end

      def render(context)
        ["---", "content: '#{@content}'", "src: '#{@src}'", "rest: '#{@rest}'"].map { |x| debug x }

        src = Liquid::Template.parse(@src).render(context)
        debug "src rendered: '#{src}'"
        img = "<img src=#{quoted src}"

        size = image_size(src, context)
        debug "image size: #{size}"
        img << " width=#{quoted size[0]} height=#{quoted size[1]}" << render_rest(context) << ">"
      end

      private

      def quoted(value)
        "#{@quote}#{value}#{@quote}"
      end

      def render_rest(context)
        rest = +""

        extra_rest = context.registers[:site].config.dig(NAME, "extra_rest")
        unless extra_rest.nil?
          extra_rest = Liquid::Template.parse(extra_rest).render(context)
          debug "extra_rest rendered: '#{extra_rest}'"
          rest << " #{extra_rest}" unless extra_rest.empty?
        end

        tag_rest = Liquid::Template.parse(@rest).render(context)
        debug "rest rendered: '#{tag_rest}'"
        rest << " #{tag_rest}" unless tag_rest.empty?

        rest
      end
    end
  end
end
