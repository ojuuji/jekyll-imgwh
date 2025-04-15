require 'cgi'
require 'fastimage'
require 'jekyll'
require 'jekyll-imgwh/version'

module Jekyll::Imgwh
  class Tag < Liquid::Tag
    def initialize(tag_name, content, tokens)
      super
      @content = content.strip
      @tag_name = tag_name
    end

    def debug(message)
      Jekyll.logger.debug "#{NAME}:", message
    end

    def render(context)
      debug "---"
      debug "content: '#{@content}'"

      if m = @content.match(/^(["'])((?:\1\1|(?!\1).)+)\1(?:\s+(.+))?$/)
        quote, src, rest = m.captures
        src = src.sub("#{quote}#{quote}", quote)

      elsif m = @content.match(/^(?!["'])((?:(?!\{\{)\S|\{\{.+?\}\})+)(?:\s+(.+))?$/)
        quote = ''
        src, rest = m.captures

      else
        raise SyntaxError, "#{NAME}: invalid #{@tag_name} tag: '#{@content}'"
      end

      debug "src: '#{src}'"
      debug "rest: '#{rest}'"

      src = Liquid::Template.parse(src).render(context)
      debug "src rendered: '#{src}'"

      path = resolve_path src, context
      size = FastImage.size(path) or raise LoadError, "#{NAME}: could not get size of image '#{path}'"
      debug "image size: #{size}"

      rest = Liquid::Template.parse(rest).render(context)
      debug "rest rendered: '#{rest}'"

      "<img src=#{quote}#{src}#{quote} width=#{quote}#{size[0]}#{quote} height=#{quote}#{size[1]}#{quote}#{rest.empty? ? "" : " #{rest}"}>"
    end

    def resolve_path(src, context)
      try_themed = true
      relative_path = CGI.unescape(src.sub(/\?.*/, ''))

      unless relative_path.start_with?('/')
        try_themed = false
        relative_path = File.join(context.registers[:page]['dir'], relative_path)
      end

      path = File.join(context.registers[:site].source, relative_path)
      debug "image path: '#{path}'"

      return path if File.file?(path)

      theme_root = context.registers[:site].config.dig(NAME, 'theme_root') or raise LoadError, "#{NAME}: image '#{path}' could not be found"
      themed_path = File.join(theme_root, relative_path)
      debug "themed image path: '#{themed_path}'"

      return themed_path if File.file?(themed_path)

      raise LoadError, "#{NAME}: none of images '#{path}', '#{themed_path}' could be found"
    end

    Liquid::Template.register_tag Jekyll::configuration().dig(NAME, 'tag_name') || 'img', self
  end
end
