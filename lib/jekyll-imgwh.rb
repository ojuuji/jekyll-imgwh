require 'jekyll'
require 'fastimage'

class JekyllImgwhTag < Liquid::Tag
  def initialize(tagName, content, tokens)
    super
    @content = content.strip
  end

  def render(context)
    prefix = "jekyll-imgwh:"
    Jekyll.logger.debug prefix, "---"
    Jekyll.logger.debug prefix, "content: '#{@content}'"

    if m = @content.match(/^(["'])((?:\1\1|(?!\1).)+)\1(.*)$/)
      quote, src, rest = m.captures
      src = src.sub("#{quote}#{quote}", quote)

    elsif m = @content.match(/^((?:(?!\{\{)\S|\{\{.+?\}\})+)(.*)$/)
      quote = '"'
      src, rest = m.captures

    else
      raise SyntaxError, "invalid img parameter: '#{@content}'"
    end

    Jekyll.logger.debug prefix, "src: '#{src}'"
    Jekyll.logger.debug prefix, "rest: '#{rest}'"

    src = Liquid::Template.parse(src).render(context)
    Jekyll.logger.debug prefix, "src rendered: '#{src}'"

    relative_path = src.sub(/\?.*/, '')
    path = File.join(context.registers[:site].source, relative_path)
    Jekyll.logger.debug prefix, "image path: '#{path}'"

    unless File.file?(path)
      theme_root = context.registers[:site].config.dig("jekyll-imgwh", "theme_root") or raise LoadError, "image '#{path}' could not be found"
      themed_path = File.join(theme_root, relative_path)
      Jekyll.logger.debug prefix, "themed image path: '#{themed_path}'"

      File.file?(themed_path) or raise LoadError, "image '#{path}' or '#{themed_path}' could not be found"
      path = themed_path
    end

    size = FastImage.size(path) or raise LoadError, "could not get size of image '#{path}'"
    Jekyll.logger.debug prefix, "image size: #{size}"

    rest = Liquid::Template.parse(rest).render(context)
    Jekyll.logger.debug prefix, "rest rendered: '#{rest}'"

    "<img src=#{quote}#{src}#{quote} width=#{quote}#{size[0]}#{quote} height=#{quote}#{size[1]}#{quote}#{rest}>"
  end

  Liquid::Template.register_tag "img", self
end
