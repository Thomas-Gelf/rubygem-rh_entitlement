require 'stringio'
require 'zlib'

module RhSubscription
  class CertificateUrls
    def initialize(raw_der_body)
      @sentinal = '*'
      @raw = raw_der_body
    end

    def list
      @urls ||= extract_urls
    end

    def has?(urls)
      urls = Array(urls)
      content_in_tree(root, urls)
    end

    private

    def root
      @root ||= build_root
    end

    def extract_urls
      @urls = []
      collect_urls root
      @urls
    end

    def collect_urls(parent, current = '')
      if parent.children.length == 0
        @urls.push current
        return
      end

      parent.children.each do |child|
        name = child.name.strip || child.name
        collect_urls(child.connection, "#{current}/#{name}")
      end
    end

    def build_root
      io = StringIO.new(@raw)
      data = Zlib::Inflate.inflate(io.read)
      end_pos = Zlib::Deflate.deflate(data).bytesize
      io.seek(end_pos)

      dictionary = data.split("\x00")
      trie = build_huffman(dictionary)
      build_path_nodes(io.read, trie)
    end

    def build_huffman(list)
      i = 1
      expanded = []
      list.each do |node|
        i.times { expanded << node }
        i += 1
      end
      i.times { expanded << @sentinal }
      HuffmanEncoding.new expanded
    end

    def build_huffman_for_nodes(list)
      i = 0
      expanded = []
      list.each do |node|
        i.times {expanded << node}
        i += 1
      end
      HuffmanEncoding.new expanded
    end

    def build_path_nodes(buf, string_trie)
      node_dict = {}
      is_count = true
      multi_count = false
      byte_count = 0
      node_count = 0
      bit_list = ''
      buf.each_byte do |byte|
        if is_count
          if !multi_count and byte > 127
            multi_count = true
            byte_count = byte - 128
            next
          end
          if multi_count
            node_count = node_count << 8
            node_count += byte
            byte_count = byte_count - 1
            multi_count = byte_count > 0
            next if multi_count
          else
            node_count += byte
          end

          node_dict = []
          node_count.times { node_dict << Node.new }
          is_count = false
        else
          bit_list += get_bits(byte)
        end
      end

      populate_node_list(node_dict, bit_list, string_trie)
    end

    def populate_node_list(node_dict, bit_list, string_trie)
      node_trie = build_huffman_for_nodes(node_dict)
      bit_start = 0
      bit_end = 0
      node_dict.each do |node|
        still_node = true
        while still_node and bit_end < bit_list.length do
          name_value = nil
          name_bits = Array.new(0)
          while name_value.to_s.empty? and still_node and bit_end < bit_list.length do
            name_bits = bit_list[bit_start..bit_end]
            bit_end += 1
            lookup_value = string_trie.decode(name_bits)
            unless lookup_value.to_s.empty?
              if lookup_value == @sentinal
                still_node = false
                bit_start = bit_end
                break
              end
              name_value = lookup_value
              bit_start = bit_end
            end
          end
          node_value = nil
          path_bits = ''
          while node_value.to_s.empty? and still_node and bit_end < bit_list.length do
            path_bits = bit_list[bit_start..bit_end]
            bit_end += 1
            lookup_value = node_trie.decode(path_bits)
            unless lookup_value.to_s.empty?
              node_value = lookup_value
              node.add_child(NodeChild.new({:name => name_value, :connection => node_value}))
              bit_start = bit_end
            end
          end
        end
      end

      node_dict[0]
    end

    def get_bits(byte)
      get_bits_rec(byte, 7)
    end

    def get_bits_rec(remain, power)
      return if power < 0

      if remain > 2**power - 1
        result = '1'
        new_val = get_bits_rec(remain - 2**power, power - 1)
      else
        result = '0'
        new_val = get_bits_rec(remain, power - 1)
      end
      unless new_val.nil?
        result += new_val
      end
      result
    end

    def content_in_tree(parent, urls)
      urls.each do |url|
        chunks = url.split("/")
        unless can_find_path(chunks[1..-1], parent)
          return false
        end
      end
      true
    end

    def can_find_path(chunks, parent)
      return true if parent.children.length == 0 and chunks.length == 0
      parent.children.each do |child|
        name = child.name.strip || child.name
        if name == chunks[0]
          return can_find_path(chunks[1..-1], child.connection)
        end
      end
      false
    end
  end

  class Node
    attr_accessor :children

    def initialize
      @children = Array.new
    end

    def add_child(child)
      @children.concat(Array.new(1, child))
    end
  end

  class NodeChild
    attr_accessor :name, :connection

    def initialize(params = {})
      @name       = params[:name] || 0
      @connection = params[:connection] || nil
    end
  end
end
