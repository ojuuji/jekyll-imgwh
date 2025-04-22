# frozen_string_literal: true

require "cgi"
require "fastimage"
require "jekyll"
require "jekyll-imgwh/version"

module Jekyll
  module Imgwh
    class Tag < Liquid::Tag
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

      def debug(message)
        Jekyll.logger.debug "#{NAME}:", message
      end

      def render(context)
        ["---", "content: '#{@content}'", "src: '#{@src}'", "rest: '#{@rest}'"].map { |x| debug x }

        src = Liquid::Template.parse(@src).render(context)
        debug "src rendered: '#{src}'"
        img = "<img src=#{@quote}#{src}#{@quote}"

        path = resolve_path(src, context)
        size = FastImage.size(path)
        raise LoadError, "#{NAME}: could not get size of image '#{path}'" unless size

        debug "image size: #{size}"
        img << " width=#{@quote}#{size[0]}#{@quote} height=#{@quote}#{size[1]}#{@quote}"

        img << render_rest(context) << ">"
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

      def resolve_path(src, context)
        path = CGI.unescape(src.sub(%r!\?.*!, ""))

        local_path = resolve_local_path(path, context)
        return local_path if File.file?(local_path)

        themed_path = resolve_themed_path(path, context) if path.start_with?("/")
        raise LoadError, "#{NAME}: '#{local_path}' could not be found" unless themed_path

        return themed_path if File.file?(themed_path)

        raise LoadError, "#{NAME}: none of '#{local_path}', '#{themed_path}' could be found"
      end

      def resolve_local_path(path, context)
        path = File.join(context.registers[:page]["dir"], path) unless path.start_with?("/")
        local_path = File.join(context.registers[:site].source, path)
        debug "image path: '#{local_path}'"

        local_path
      end

      def resolve_themed_path(path, context)
        themed_path = context.registers[:site].in_theme_dir(path)
        debug "themed image path: '#{themed_path}'"

        themed_path
      end

      Liquid::Template.register_tag "imgwh", self
    end
  end
end
