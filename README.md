A [Jekyll](https://jekyllrb.com/) plugin to simplify maintenance of HTML `<img>` elements, which ensures image still exists and automatically fills  `width` and `height` attributes. The latter helps to avoid layout shift when the image is downloaded and painted to the screen, which is a major component of good user experience and web performance.

# Installation

Add preferred variant from the following to your site's `Gemfile` and run `bundle install`:

```ruby
gem "jekyll-imgwh", group: :jekyll_plugins
gem "jekyll-imgwh", group: :jekyll_plugins, git: "https://github.com/ojuuji/jekyll-imgwh"
gem "jekyll-imgwh", group: :jekyll_plugins, path: "/local/path/to/jekyll-imgwh"
```

# Usage

This plugin exposes Liquid tag `imgwh` with the following syntax:

```liquid
{% imgwh <src> [<rest>] %}
```

i.e. `<src>` is required and `<rest>` is optional. They both can have Liquid markup.

After rendering, `<rest>` is added to generated HTML `<img>` element as-is, and `<src>` is used as a value for `src` attribute.

Plugin extracts size of the referenced image and automatically sets `width` and `height` attributes in the generated HTML `<img>` element.

Extra whitespace around `<src>` and `<rest>` is stripped.

Example:

```liquid
{%    imgwh     "/assets/{{ site.title | slugify }}.png"     alt="{{ site.title }}"       %}
```

with `site.title="My Site"` and image size 200x67 it would generate the following HTML `<img>` element:

```html
<img src="/assets/my-site.png" width="200" height="67" alt="My Site">
```

## Quotes and Whitespace

`<src>` can be specified with single quotes, double quotes, or without quotes. This also defines quotation for the generated `src`, `width`, and `height` attributes: they always use the same quotes as `<src>`:

```
{% imgwh "/foo.png" %} -> <img src="/foo.png" width="123" height="456">
{% imgwh '/foo.png' %} -> <img src='/foo.png' width='123' height='456'>
{% imgwh  /foo.png  %} -> <img src=/foo.png width=123 height=456>
```

Whitespace can be freely used in single- and double-quoted `<src>`. To use the same quote character in the `<src>` value specify it twice:

```
{% imgwh "/f{{  'oo'  | append: "".png"" }}" %} -> OK (src="/foo.png")
{% imgwh "/f{{  'oo'  | append:  ".png"  }}" %} -> ERROR
{% imgwh '/f{{  'oo'  | append:  ".png"  }}' %} -> ERROR
{% imgwh '/f{{ ''oo'' | append:  ".png"  }}' %} -> OK (src='/foo.png')
```

For unquoted `<src>` whitespace is allowed only within Liquid filters (i.e. between `{{` and `}}`):


```
{% imgwh  /f{{  'oo'  | append:  ".png"  }}  %} -> OK (src=/foo.png)
{% imgwh /My Site.png %}          -> ERROR (tries to open "/My" image)
{% imgwh /{{ site.title }}.png %} -> OK (src=/My Site.png)
```

Note, in the last example, although plugin did not fire an error, generated `src` attribute is not valid (image would use `src=/My`). After rendering Liquid markup in the `<src>` value, plugin does not perform any further normalization for the resulting URI. It is up to the caller to provide correct URI, and plugin will extract and URL-decode path from it.

## Path Resolution

When the image path is absolute, image is searched relative to the site source directory.

When the image path is relative, image is searched relative to the directory of the current page (`page.dir`).

When the image is not found, and a theme is used, and the path is absolute, image is also searched relative to the theme root directory.

## Error Handling

If plugin cannot generate HTML `<img>` element (due to a syntax error, Liquid markup error, image being nonexistent, not an image, etc.) plugin unconditionally raises an error which stops site generation.

# Configuration

This plugin uses the following configuration options by default. The configuration file is the same as Jekyll's (which is `_config.yml` unless overridden):

```yml
jekyll-imgwh:
  extra_rest:
```

These are default options i.e. you do not need to specify any of them unless you want to use different value.

### `extra_rest`

Remember tag syntax? This option inserts additional text to all generated images. So we may say the tag syntax is actually this:

```liquid
{% imgwh <src> <extra_rest> [<rest>] %}
```

For example, since all generated HTML `<img>` elements get the size attributes, it might be a good idea to set lazy loading for the images:

```yml
jekyll-imgwh:
  extra_rest: loading="lazy"
```

# Troubleshooting

When error is related to the image image file, it mentions file path in the error message:

```
$ bundle exec jekyll serve
<...>
  Liquid Exception: jekyll-imgwh: 'Y:/ssg/www/assets/images/logo/foo.png' could not be found in index.html
<...>
```

Plugin also logs a lot of info which can help to resolve errors raised by it. Use `jekyll serve --verbose` flag to output this debug info.

Example markup:
```
{% imgwh "/assets/images/logo/{{ product.key }}.png" alt="{{ project.title }} Logo" class="www-logo" %}
```

Here is full round of debug messages for it in case of successful generation:
```
$ bundle exec jekyll serve --verbose
<...>
      jekyll-imgwh: ---
      jekyll-imgwh: content: '"/assets/images/logo/{{ product.key }}.png" alt="{{ project.title }} Logo" class="www-logo"'
      jekyll-imgwh: src: '/assets/images/logo/{{ product.key }}.png'
      jekyll-imgwh: rest: 'alt="{{ project.title }} Logo" class="www-logo"'
      jekyll-imgwh: src rendered: '/assets/images/logo/foo.png'
      jekyll-imgwh: image path: 'Y:/ssg/www/assets/images/logo/foo.png'
      jekyll-imgwh: image size: [128, 64]
      jekyll-imgwh: rest rendered: 'alt="My Product Logo" class="www-logo"'
  <...>
```
