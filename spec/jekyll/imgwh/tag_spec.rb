# frozen_string_literal: true

describe Jekyll::Imgwh::Tag do
  let(:overrides) { {} }
  let(:output) do
    site = Jekyll::Site.new(Jekyll.configuration(overrides.merge({ "source" => source })))
    relations = { :site => site, :collection => Jekyll::Collection.new(site, "test") }
    doc = Jekyll::Document.new(source("home/doc.html"), relations)
    doc.content = content
    doc.output = Jekyll::Renderer.new(doc.site, doc).run
  end

  context "when path not found" do
    let(:content) { '{% imgwh "/not/exists.png" %}' }

    it "raises mentioning given path" do
      expect { output }.to raise_error(LoadError, %r!/not/exists.png' could not be found$!)
    end
  end

  context "when path has liquid" do
    let(:content) { %({% imgwh "{{ '/123' | append: 'x67.png' }}" %}) }

    it "is rendered" do
      expect(output).to include('src="/123x67.png"')
    end
  end

  context "with double quoted path" do
    let(:content) { '{% imgwh "/123x67.png" %}' }

    it "produces attrs with double quotes" do
      expect(output).to match('<img src="/123x67.png" width="123" height="67">')
    end

    context "when need to escape double quote in path" do
      let(:content) { '{% imgwh "{{ ""/123"" | append: ""x67.png"" }}" %}' }

      it "expects two double quotes" do
        expect(output).to include('src="/123x67.png"')
      end
    end
  end

  context "with single quoted path" do
    let(:content) { "{% imgwh '/123x67.png' %}" }

    it "produces attrs with single quotes" do
      expect(output).to match("<img src='/123x67.png' width='123' height='67'>")
    end

    context "when need to escape single quote in path" do
      let(:content) { "{% imgwh '{{ ''/123'' | append: ''x67.png'' }}' %}" }

      it "expects two single quotes" do
        expect(output).to include("src='/123x67.png'")
      end
    end
  end

  context "with unquoted path" do
    let(:content) { "{% imgwh /123x67.png %}" }

    it "produces attrs without quotes" do
      expect(output).to match("<img src=/123x67.png width=123 height=67>")
    end

    context "when whitespace is in liquid" do
      let(:content) { "{% imgwh /12{{ '3' | append: \"x67\"}}.png %}" }

      it "is allowed" do
        expect(output).to include("src=/123x67.png")
      end
    end

    context "when whitespace is in path" do
      let(:content) { "{% imgwh /12  34.png %}" }

      it "is treated as separator" do
        expect { output }.to raise_error(LoadError, %r!/12' could not be found$!)
      end
    end
  end

  context "when there is extra whitespace around tag" do
    let(:content) { '{% imgwh      "/123x67.png"        %}' }

    it "is stripped" do
      expect(output).to match('<img src="/123x67.png" width="123" height="67">')
    end
  end

  context "when the rest is set" do
    let(:content) { %({% imgwh '/123x67.png' alt="hello" %}) }

    it "appends rest to the end" do
      expect(output).to match(%(<img src='/123x67.png' width='123' height='67' alt="hello">))
    end

    context "when there is extra whitespace before the rest" do
      let(:content) { "{% imgwh '/123x67.png'      \t\n   alt='hello' %}" }

      it "is stripped" do
        expect(output).to match("<img src='/123x67.png' width='123' height='67' alt='hello'>")
      end
    end

    context "when there is no whitespace before the rest" do
      let(:content) { '{% imgwh "/123x67.png"alt="hello" %}' }

      it "raises" do
        expect { output }.to raise_error(SyntaxError, %r!invalid !)
      end
    end

    context "when it has liquid" do
      let(:overrides) { { "title" => "My Site" } }
      let(:content) { '{% imgwh "/123x67.png" alt="This is {{ site.title }}" %}' }

      it "is rendered" do
        expect(output).to include('alt="This is My Site"')
      end
    end
  end

  context "with theme" do
    let(:overrides) { { "theme" => "jekyll-imgwh-test-theme" } }
    let(:content) { "{% imgwh /assets/544x304.png %}" }

    it "loads images from theme" do
      expect(output).to include("img src=/assets/544x304.png width=544 height=304")
    end

    context "when image is not found" do
      let(:content) { "{% imgwh /nope.png %}" }

      it "mentions both paths" do
        expect { output }.to raise_error(
          LoadError, %r! none of '.+/site/nope.png', '.+/theme/nope.png' could be found$!
        )
      end
    end
  end

  context "with extra_rest option" do
    let(:overrides) { { "jekyll-imgwh" => { "extra_rest" => 'loading="lazy"' } } }
    let(:content) { "{% imgwh /123x67.png alt='Hi' %}" }

    it "inserts extra_rest before rest" do
      expect(output).to match("<img src=/123x67.png width=123 height=67 loading=\"lazy\" alt='Hi'")
    end

    context "when extra_rest has liquid" do
      let(:overrides) { { "jekyll-imgwh" => { "extra_rest" => '<!--{{ "X" | append: "Y" }}-->' } } }
      let(:content) { "{% imgwh /123x67.png %}" }

      it "is rendered" do
        expect(output).to include("<!--XY-->")
      end
    end
  end

  context "when given uri with scheme" do
    let(:content) { '{% imgwh "http://example.com/123x67.png" %}' }

    it "raises" do
      expect { output }.to raise_error(ArgumentError, %r!URIs with 'http' scheme are not allowed$!)
    end

    context "when uri scheme is in allowed_schemes option" do
      let(:overrides) { { "jekyll-imgwh" => { "allowed_schemes" => ["data"] } } }
      let(:content) { "{% imgwh data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iOSIgaGVpZ2h0PSI1Ii8+ %}" }

      it "processes image" do
        expect(output).to include("width=9 height=5")
      end
    end
  end
end
