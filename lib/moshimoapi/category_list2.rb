require 'rubygems'
require 'xml/libxml'
require 'open-uri'

module MoshimoAPI

  class CategoryList2 

    CATEGORY_LIST2_URL = 'http://api.moshimo.com/category/list2'
    AUTHORIZATION_PARAM = 'authorization_code'
    AUTHORIZATION_CODE = "WpJCUaylbBahlDF4536egtyO6Ah7d"

    def get_category_data
      categories= self.get_categories( nil, true )
      list = []
      categories.each do | c |
        collect_hash_data( c, list)
      end
      return list
    end


    def get_categories( code = nil, recursible = false, depth = 9999, model = nil )
      if model && depth <= 1
        return
      end

      model = nil unless code

      category = model
      if category.nil? || ( recursible && depth > 1 )
        category = get_category( code ) 
        if model && recursible && depth > 1 
          model.children = category.children
        end
      end

      if category
        depth -= 1 unless category.code.nil?
        if depth > 1
          category.children.each do | child |
            self.get_categories( child.code, recursible, depth, child)
          end
        end
      end
      return code.nil? ? category.children : category
    end

    class CategoryParser
      def initialize(category_xml)
        @xp = XML::Parser.string(category_xml)
        @ns = {
#         'foaf'  => 'http://xmlns.com/foaf/0.1/',
#         'prism' => 'http://prismstandard.org/namespaces/basic/2.0/',
#         'con'   => 'http://www.w3.org/2000/10/swap/pim/contact#'
        }
        @xpath = {
          :status => '//Result/Status',
          :reason => '//Result/Reason',
          :category => '//Category',
          :code => './Code',
          :name => './Name',
          :level => './Level',
          :children => './Children/Child',
          :parents => './Parents/Parent'
        }
      end

      def parse
        doc = @xp.parse
        result = doc.find_first(@xpath[:status]).inner_xml
        unless result.to_s == 'OK'
          reason = doc.find_first(@xpath[:reason]).inner_xml
          raise "get_category fail reason=[#{reason}]"
        end

        category = nil
        node_category = doc.find_first(@xpath[:category])
        if node_category
          if node_category.find(@xpath[:code])
            category = create_category(node_category)
            category.children = node_category.find(@xpath[:children]).map{| node | create_category(node)}
            category.parents = node_category.find(@xpath[:parents]).map{|node| create_category(node)}
          end
        end
        return category
      end

      private

      def create_category(node)
        code = node.find_first(@xpath[:code]).inner_xml
        name = node.find_first(@xpath[:name]).inner_xml
        level = node.find_first(@xpath[:level]).inner_xml

        return Category.new(code, name, level)
      end

    end

    class Category
 
      attr_accessor :code, :name, :level
      attr_accessor :children, :parents

      def initialize( code, name, level)
        @code = code
        @name = name
        @level = level
        @children = []
        @parents = []
      end

      def has_children?
        @children.size > 0
      end

      def to_hash
        {
          :code => @code,
          :name => @name,
          :level => @level
        }
      end

      def p_tree(sp = nil)
        p "#{sp}#{code}"
        self.children.each do | c |
          c.p_tree( " #{sp}")
        end
      end
    end


    private

    def category2_url( code = nil )
      url = "#{CATEGORY_LIST2_URL}?#{AUTHORIZATION_PARAM}=#{AUTHORIZATION_CODE}"
      article_category_code = "&article_category_code=#{code}"
      unless code
        article_category_code = ""
      end
      "#{url}#{article_category_code}"
    end

    def get_category( code =nil )
      xml = ""
      url = category2_url(code)
      p url
      open( url ) do | str_io |
        xml = str_io.read
      end
      sleep(0.7)
      c = CategoryParser.new(xml).parse()
      return c
    end
 
    def collect_hash_data( category, list = [] )
      list << category.to_hash
      category.children.each do | c |
        collect_hash_data(c, list)
      end
      return list
    end

  end
end


