# frozen_string_literal: true

require_relative './tags'

module Papercraft  
  # HTML Markup extensions
  module HTML
    include Tags

    # Emits the p tag (overrides Object#p)
    #
    # @param text [String] text content of tag
    # @param props [Hash] tag attributes
    # @para block [Proc] nested HTML block
    # @return [void]
    def p(text = nil, **props, &block)
      method_missing(:p, text, **props, &block)
    end

    S_HTML5_DOCTYPE = '<!DOCTYPE html>'

    # Emits an HTML5 doctype tag and an html tag with the given block.
    #
    # @param block [Proc] nested HTML block
    # @return [void]
    def html5(&block)
      @buffer << S_HTML5_DOCTYPE
      self.html(&block)
    end

    # Emits a link element with a stylesheet.
    #
    # @param href [String] stylesheet URL
    # @param custom_attributes [Hash] optional custom attributes for the link element
    # @return [void]
    def link_stylesheet(href, custom_attributes = nil)
      attributes = {
        rel: 'stylesheet',
        href: href
      }
      if custom_attributes
        attributes = custom_attributes.merge(attributes)
      end
      link(**attributes)
    end

    # Emits an inline CSS style element.
    #
    # @param css [String] CSS code
    # @param **props [Hash] optional element attributes
    # @return [void]
    def style(css, **props, &block)
      @buffer << '<style'
      emit_props(props) unless props.empty?

      @buffer << '>' << css << '</style>'
    end
  
    # Emits an inline JS script element.
    #
    # @param js [String, nil] Javascript code
    # @param **props [Hash] optional element attributes
    # @return [void]
    def script(js = nil, **props, &block)
      @buffer << '<script'
      emit_props(props) unless props.empty?

      if js
        @buffer << '>' << js << '</script>'
      else
        @buffer << '></script>'
      end
    end
  
    # Converts and emits the given markdown. Papercraft uses
    # [Kramdown](https://github.com/gettalong/kramdown/) to do the Markdown to
    # HTML conversion. Optional Kramdown settings can be provided in order to
    # control the conversion. Those are merged with the default Kramdown
    # settings, which can be controlled using
    # `Papercraft::HTML.kramdown_options`.
    #
    # @param markdown [String] Markdown content
    # @param **opts [Hash] Kramdown options
    # @return [void]
    def emit_markdown(markdown, **opts)
      emit Papercraft.markdown(markdown, **opts)
    end

    private

    # Returns true if the given tag is a void element, in order to render a self
    # closing tag. See spec: https://html.spec.whatwg.org/multipage/syntax.html#void-elements.
    #
    # @param text [String] tag
    # @return [Bool] is it a void element
    def is_void_element_tag?(tag)
      case tag
      # 
      when 'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source', 'track', 'wbr'
        true
      else
        false
      end
    end

    # Escapes the given text using HTML entities.
    #
    # @param text [String] text
    # @return [String] escaped text
    def escape_text(text)
      EscapeUtils.escape_html(text.to_s)
    end

    # Converts a tag to its string representation. Underscores will be converted
    # to dashes.
    #
    # @param tag [Symbol, String] tag
    # @return [String] tag string
    def tag_repr(tag)
      tag.to_s.tr('_', '-')
    end

    # Converts an attribute to its string representation. Underscores will be
    # converted to dashes.
    #
    # @param att [Symbol, String] attribute
    # @return [String] attribute string
    def att_repr(att)
      att.to_s.tr('_', '-')
    end
  end
end
