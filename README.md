[![Gem Version](https://badge.fury.io/rb/jekyll-imgwh.svg)](https://badge.fury.io/rb/jekyll-imgwh)

A [Jekyll](https://jekyllrb.com/) plugin to simplify maintenance of the images on the site.

It provides a [Liquid tag `imgwh`](#liquid-tag) for `<img>` elements, which ensures image still exists and automatically fills `width` and `height` attributes allowing image to take up space before it loads, to mitigate content layout shifts.

It also provides a [Liquid filter `imgwh`](#liquid-filter), which returns image size as an array.

# Installation

Add preferred variant from the following ones to your site's `Gemfile` and run `bundle install`:

```ruby
gem "jekyll-imgwh", group: :jekyll_plugins
gem "jekyll-imgwh", group: :jekyll_plugins, git: "https://github.com/ojuuji/jekyll-imgwh"
gem "jekyll-imgwh", group: :jekyll_plugins, path: "/local/path/to/jekyll-imgwh"
```

# Usage

## Liquid Tag

This plugin exposes Liquid tag `imgwh` with the following syntax:

```liquid
{% imgwh <src> [<rest>] %}
```

i.e. `<src>` is required and `<rest>` is optional. They both can include Liquid markup.

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

### Quotes and Whitespace

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
{% imgwh /My Site.png %}                        -> ERROR (tries to open "/My" image)
{% imgwh /{{ site.title }}.png %}               -> OK (src=/My Site.png)
```

Note, in the last example, although plugin did not fire an error, generated `src` attribute is not valid (`<img>` element would use `src=/My`). After rendering Liquid markup in the `<src>` value, plugin does not perform any further normalization for the resulting URI. It is up to the caller to provide correct URI. Plugin only extracts and URL-decodes the path from it.

## Liquid Filter

This plugin exposes a Liquid filter `imgwh`, which returns image size as an array.

It accepts no extra arguments and follows the same [path resolution](#path-resolution) rules as the tag.

For example, if `/assets/images/logo.png` size is 520x348, this template

```liquid
<pre>
  {{ "/assets/images/logo.png" | imgwh | inspect }}
  {{ "/assets/images/logo.png" | imgwh | first }}
  {{ "/assets/images/logo.png" | imgwh | last }}
</pre>
```

would render to

```html
<pre>
  [520, 348]
  520
  348
</pre>
```

## Path Resolution

When the given URI contains scheme, plugin raises an error unless this scheme is listed in [`allowed_schemes`](#allowed_schemes) option (which is empty by default). In case of allowed scheme plugin tries to retrieve image size using the given URI as-is.

For URIs without scheme plugin uses URL-decoded path from URI to find image on the local filesystem.

When the image path is absolute, image is searched relative to the site source directory.

When the image path is relative, image is searched relative to the directory of the current page (`page.dir`).

When the image is not found, and a theme is used, and the path is absolute, image is also searched relative to the theme root directory.

## Error Handling

In case plugin cannot determine the image size (due to a syntax error, Liquid template error, image being nonexistent, not an image, etc.) it unconditionally raises an error which stops the site generation.

# Configuration

This plugin uses the following configuration options by default. The configuration file is the same as Jekyll's (which is `_config.yml` unless overridden):

```yml
jekyll-imgwh:
  allowed_schemes: []
  extra_rest:
```

These are default options i.e. you do not need to specify any of them unless you want to use different value.

### `allowed_schemes`

By default plugin allows only local image files to be used. This means if the given image URI contains non-empty scheme, plugin raises an error.

Option `allowed_schemes` adds exception for the schemes specified in it. For URIs with allowed schemes plugin will try to access them and retrieve the image size.

For example, to allow HTTPS image URLs and [data URLs](https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Schemes/data) use the following:

```yml
jekyll-imgwh:
  allowed_schemes: ["data", "https"]
```

### `extra_rest`

Remember `imgwh` tag syntax? This option injects additional text into all generated HTML `<img>` elements. So we may say the tag syntax is actually this:

```liquid
{% imgwh <src> <extra_rest> [<rest>] %}
```

For example, since all generated HTML `<img>` elements get the size attributes, it might be a good idea to set lazy loading for the images:

```yml
jekyll-imgwh:
  extra_rest: loading="lazy"
```

# Troubleshooting

When error is related to the image image file, plugin mentions the file path in the error message:

```
$ bundle exec jekyll serve
<...>
  Liquid Exception: jekyll-imgwh: 'Y:/ssg/assets/images/foo.png' could not be found in index.html
<...>
```

Plugin also logs a lot of info which can help to resolve errors raised by it. Use `jekyll serve --verbose` flag to output this debug info.

For example, for template

```
{% imgwh "/assets/images/{{ product.key }}.png" alt="{{ project.title }} Logo" class="www-logo" %}
```

it would print something like this in case of successful generation:

```
$ bundle exec jekyll serve --verbose
<...>
      jekyll-imgwh: ---
      jekyll-imgwh: content: '"/assets/images/{{ product.key }}.png" alt="{{ project.title }} Logo" class="www-logo"'
      jekyll-imgwh: src: '/assets/images/{{ product.key }}.png'
      jekyll-imgwh: rest: 'alt="{{ project.title }} Logo" class="www-logo"'
      jekyll-imgwh: src rendered: '/assets/images/foo.png'
      jekyll-imgwh: image path: 'Y:/ssg/assets/images/foo.png'
      jekyll-imgwh: image size: [128, 64]
      jekyll-imgwh: rest rendered: 'alt="My Product Logo" class="www-logo"'
<...>
```

# Development

To get started with the development:

```sh
git clone https://github.com/ojuuji/jekyll-imgwh.git
cd jekyll-imgwh
bundle install
bundle exec rspec
```
