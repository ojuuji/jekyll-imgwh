require 'jekyll'
require 'fastimage'
require_relative 'jekyll-imgwh/version'

module Jekyll::Imgwh
  class Tag < Liquid::Tag
    def initialize(tag_name, content, tokens)
      super
      @content = content.strip
    end

    def debug(message)
      Jekyll.logger.debug "#{NAME}:", message
    end

    def render(context)
      debug "---"
      debug "content: '#{@content}'"

      if m = @content.match(/^(["'])((?:\1\1|(?!\1).)+)\1(.*)$/)
        quote, src, rest = m.captures
        src = src.sub("#{quote}#{quote}", quote)

      elsif m = @content.match(/^((?:(?!\{\{)\S|\{\{.+?\}\})+)(.*)$/)
        quote = '"'
        src, rest = m.captures

      else
        raise SyntaxError, "invalid img parameter: '#{@content}'"
      end

      debug "src: '#{src}'"
      debug "rest: '#{rest}'"

      src = Liquid::Template.parse(src).render(context)
      debug "src rendered: '#{src}'"

      relative_path = src.sub(/\?.*/, '')
      path = File.join(context.registers[:site].source, relative_path)
      debug "image path: '#{path}'"

      unless File.file?(path)
        theme_root = context.registers[:site].config.dig(NAME, "theme_root") or raise LoadError, "image '#{path}' could not be found"
        themed_path = File.join(theme_root, relative_path)
        debug "themed image path: '#{themed_path}'"

        File.file?(themed_path) or raise LoadError, "none of images '#{path}', '#{themed_path}' could be found"
        path = themed_path
      end

      size = FastImage.size(path) or raise LoadError, "could not get size of image '#{path}'"
      debug "image size: #{size}"

      rest = Liquid::Template.parse(rest).render(context)
      debug "rest rendered: '#{rest}'"

      "<img src=#{quote}#{src}#{quote} width=#{quote}#{size[0]}#{quote} height=#{quote}#{size[1]}#{quote}#{rest}>"
    end

    Liquid::Template.register_tag "img", self
  end
end
