module UniqueHtmlExtractonator

  # Extract unique content from HTML using +:reference_html+ for comparison.
  # Designed to extract only significant content from page with layout,
  # skipping all common elements like header or footer.
  # == How it works
  # It works by visiting all Text nodes in +:html+ document, trying to find
  # its existence in +:reference_html+. When it fails to do so it marks element
  # to be preserved.
  #
  # == Preservation
  #
  # Some texts can be embedded in tables, then preserving only containing <td> may be not enough,
  # in such cases +:preserved_tags_order+ param is used which by defaults will look for <td> ancestor
  # and mark it for preservation
  class Extractor
    Error = Class.new(StandardError)
    PRESERVED_TAGS_ORDER = { 'td' => 'tr', 'th' => 'tr', 'li' => ['ul','ol'] }
    DISCARDED_ELEMENTS = %w( img a style )
    DISCARDED_ATTRIBUTES = %w( class style id )

    def self.options_accessor_hash(*args)
      args.each do |accessor|
        class_eval <<-END
          def #{accessor}_hash
            @#{accessor}_hash ||= @options[:#{accessor}].each_with_object(Hash.new()) { |element,acc| acc[element.to_s.downcase] = true }
          end
        END
      end
    end

    # ==== Options
    #
    # You may which to break out options as a separate item since there maybe
    # multiple items. Note options are prefixed with a colon, denoting them
    # as a # #
    # * +:reference_html+ - A HTML used as reference
    # * +:html+ - A HTML that needs extraction
    # * +:preserved_tags_order+ - A hash specifying exceptions in tag preservation hierarchy
    # * +:discarded_elements+ - An array of html tags to discard
    # * +:discarded_attributes+ - An array of html attributes to discard
    def initialize(options={})
      @options = { preserved_tags_order: PRESERVED_TAGS_ORDER, discarded_elements: DISCARDED_ELEMENTS,
        discarded_attributes: DISCARDED_ATTRIBUTES }.merge(options)
    end

    attr_accessor :preserved_elements

    def extract
      @preserved_elements = {}
      xml = create_dom(@options[:html])
      parse_element(xml)
      remove_duplicates
      # p @preserved_elements
      tidy_extracted_html
    end

    private

    options_accessor_hash :discarded_elements, :discarded_attributes

    def preserved_tags_order_hash
      @options[:preserved_tags_order]
    end

    def create_dom(html)
      Nokogiri::HTML(html) do |config|
        config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NONET | Nokogiri::XML::ParseOptions::NOBLANKS
      end
    end

    def tidy_extracted_html
      file = Tempfile.new ["extracted","html"]
      file.write @preserved_elements.keys.map(&:to_s).join("\n")
      file.rewind

      outfile = Tempfile.new ["extracted-tidy","html"]

      command = "tidy -asxhtml -utf8 -output #{outfile.path.to_s} #{file.path.to_s} 2>/dev/null"

      @output = `#{command}`.strip.force_encoding('UTF-8')
      @exitstatus = $?.exitstatus

      raise Error, "#{@output.strip}. Exitstatus: #{@exitstatus.to_s.force_encoding('UTF-8')}." if @exitstatus > 1

      outfile.rewind
      tidied_html = outfile.read

      dom = create_dom(tidied_html)
      dom.search('//body').first.inner_html.lstrip
    end

    # remove "duplicates", from following
    #   <h3>txt1</h3>
    #   <div><h3>txt1</h3>txt2</div>
    # first <h3> should be removed as it's part of second element
    def remove_duplicates
      all_preserved_elements = @preserved_elements.keys.collect do |element|
        children = element.xpath('.//*')
        [element,children]
      end.flatten
      preserved_elements_counter = all_preserved_elements.each_with_object(Hash.new(0)) { |e,total| total[e] += 1 }
      preserved_elements_counter.each do |element,counts|
        if counts > 1
          @preserved_elements.delete(element)
        else
          @options[:discarded_elements].each do |tag|
            element.xpath("/descendant-or-self::#{tag}").map(&:remove)
          end
          @options[:discarded_attributes].each do |attr|
            element.xpath("/descendant-or-self::node()[@#{attr}]").map do |node|
              node.remove_attribute(attr)
            end
          end
          # remove linebreaks before text
          element.search('.//text()/preceding-sibling::br').map(&:remove)
        end
      end
    end

    def element_discarded?(tag_name)
      discarded_elements_hash[tag_name.to_s.downcase]
    end

    def reference_html
      @reference_html ||= create_dom(@options[:reference_html])
    end

    def reference_html_texts
      @reference_html_texts ||= reference_html.search('//text()').map(&:text)
    end

    def parse_element(element)
      element.children.each do |child|
        if child.is_a?(Nokogiri::XML::Element) && element_discarded?(child.name)
          next
        elsif child.is_a?(Nokogiri::XML::Text)
          if child.text.strip.present?
            # don't use element path as it does not produce any meaningful results
            # if current text cannot be found in reference document, mark node for preservation
            unless reference_html_texts.include? child.text.strip
              # eg. for td element preserve whole tr element
              # binding.pry if child.text.strip =~/FETCHME/
              if next_ancestor = preserved_tags_order_hash[element.name]
                if next_ancestor.respond_to? :each
                  ancestor_node = next_ancestor.collect do |next_ancestor_tag|
                    element.ancestors.find { |anc| anc.name == next_ancestor_tag }
                  end.compact.sort_by { |ancestor| ancestor.path }.last || element
                  preserved_elements[ancestor_node] = true
                else
                  ancestor_node = element.ancestors.find { |anc| anc.name == next_ancestor } || element
                  preserved_elements[ancestor_node] = true
                end
              else
                preserved_elements[element] = true
              end
            end
          end
        else
          parse_element(child)
        end
      end
    end
  end
end
