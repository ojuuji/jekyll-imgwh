# frozen_string_literal: true

require "cgi"
require "fastimage"
require "jekyll"
require "jekyll/imgwh/version"
require "uri"

module Jekyll
  module Imgwh
    module Helpers
      def debug(message)
        Jekyll.logger.debug "#{NAME}:", message
      end

      def image_size(src, context)
        uri = URI(src)

        if uri.scheme.nil?
          src = resolve_path(CGI.unescape(uri.path), context)
        else
          allowed_schemes = context.registers[:site].config.dig(NAME, "allowed_schemes") || []
          unless allowed_schemes.include?(uri.scheme)
            raise ArgumentError, "#{NAME}: URIs with '#{uri.scheme}' scheme are not allowed"
          end
        end

        FastImage.size(src) or raise LoadError, "#{NAME}: could not get size of image '#{src}'"
      end

      def resolve_path(path, context)
        local_path = path.start_with?("/") ? path : File.join(context.registers[:page]["dir"], path)
        local_path = File.join(context.registers[:site].source, local_path)
        debug "image path: '#{local_path}'"
        return local_path if File.file?(local_path)

        themed_path = context.registers[:site].in_theme_dir(path) if path.start_with?("/")
        raise LoadError, "#{NAME}: '#{local_path}' could not be found" unless themed_path

        debug "themed image path: '#{themed_path}'"
        return themed_path if File.file?(themed_path)

        raise LoadError, "#{NAME}: none of '#{local_path}', '#{themed_path}' could be found"
      end
    end
  end
end
