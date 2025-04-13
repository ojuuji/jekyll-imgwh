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

    path = File.join(context.registers[:site].source, src).sub(/\?.*/, '')
    Jekyll.logger.debug prefix, "image path: '#{path}'"
    File.file?(path) or raise LoadError, "image file '#{path}' could not be found"

    size = FastImage.size(path) or raise LoadError, "could not get size of image file '#{path}'"
    Jekyll.logger.debug prefix, "image size: #{size}"

    rest = Liquid::Template.parse(rest).render(context)
    Jekyll.logger.debug prefix, "rest rendered: '#{rest}'"

    "<img src=#{quote}#{src}#{quote} width=#{quote}#{size[0]}#{quote} height=#{quote}#{size[1]}#{quote}#{rest}>"
  end

  Liquid::Template.register_tag "img", self
end
