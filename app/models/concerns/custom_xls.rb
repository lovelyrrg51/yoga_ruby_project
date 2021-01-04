module CustomXls

  module XML
    XML_ESCAPES = {
      '&' => '&amp;',
      '"' => '&quot;',
      '<' => '&lt;',
      '>' => '&gt;',
    }.freeze

    XML_DECLARATION = %'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n'.freeze

    WS_AROUND_TAGS = /(?<=>)\s+|\s+(?=<)/.freeze

    UNSAFE_ATTR_CHARS = /[&"<>]/.freeze
    UNSAFE_VALUE_CHARS = /[&<>]/.freeze

    class << self

      def header
        XML_DECLARATION
      end

      def strip(xml)
        xml.gsub(WS_AROUND_TAGS, ''.freeze)
      end

      def escape_attr(string)
        string.gsub(UNSAFE_ATTR_CHARS, XML_ESCAPES)
      end

      def escape_value(string)
        string.gsub(UNSAFE_VALUE_CHARS, XML_ESCAPES)
      end

    end


  end

  class Row
    
    def initialize(row)
      @row = row
      @encoding = Encoding.find("UTF-8")
    end

    def to_xml

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Row {
          @row.each do |r|
            xml.Cell {
              xml.Data_ CustomXls::XML.escape_value(r.to_s), "ss:Type" => "String"
            }
          end
        }
      end

      CustomXls::XML.strip(builder.doc.root.to_s)

    end

  end

  class << self

    def header

      CustomXls::XML.strip(<<-XML)
        <?xml version="1.0"?>
          <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
            xmlns:o="urn:schemas-microsoft-com:office:office"
            xmlns:x="urn:schemas-microsoft-com:office:excel"
            xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
            xmlns:html="http://www.w3.org/TR/REC-html40">
            <Worksheet ss:Name="Sheet1">
              <Table>
      XML

    end

    def footer
      
      CustomXls::XML.strip(<<-XML)
          </Table>
          </Worksheet>
        </Workbook>
      XML

    end

  end
  
end
