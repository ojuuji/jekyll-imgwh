# frozen_string_literal: true

require "cgi"
require "fastimage"
require "jekyll"
require "uri"

module Jekyll
  module Imgwh
    module Helpers
      def name
        "imgwh"
      end

      def debug(*messages)
        messages.each { |message| Jekyll.logger.debug "#{name}:", message }
      end

      def image_size(src, context)
        uri = URI(src)

        if uri.scheme.nil?
          src = resolve_path(CGI.unescape(uri.path), context)
        else
          allowed_schemes = context.registers[:site].config.dig(name, "allowed_schemes") || []
          unless allowed_schemes.include?(uri.scheme)
            raise ArgumentError, "#{name}: URIs with '#{uri.scheme}' scheme are not allowed"
          end
        end

        FastImage.size(src) or raise LoadError, "#{name}: could not get size of image '#{src}'"
      end

      def resolve_path(path, context)
        local_path = path.start_with?("/") ? path : File.join(context.registers[:page]["dir"], path)
        local_path = context.registers[:site].in_source_dir(local_path)
        debug "image path: '#{local_path}'"
        return local_path if File.file?(local_path)

        themed_path = context.registers[:site].in_theme_dir(path) if path.start_with?("/")
        raise LoadError, "#{name}: '#{local_path}' could not be found" unless themed_path

        debug "themed image path: '#{themed_path}'"
        return themed_path if File.file?(themed_path)

        raise LoadError, "#{name}: none of '#{local_path}', '#{themed_path}' could be found"
      end
    end
  end
end
