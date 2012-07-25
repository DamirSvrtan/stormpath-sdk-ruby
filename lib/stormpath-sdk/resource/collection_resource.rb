module Stormpath

  module Resource

    class CollectionResource < Resource

      OFFSET = "offset"
      LIMIT = "limit"
      ITEMS = "items"

      def each(&block)
        get_current_page.items.each(&block)
      end

      protected

      def get_offset
        get_property OFFSET
      end

      def get_limit
        get_property LIMIT
      end

      def get_current_page

        value = get_property ITEMS
        items = to_resource_array value

        Page.new get_offset, get_limit, items
      end

      def to_resource clazz, properties
        self.dataStore.instantiate clazz, properties
      end

      private

      def to_resource_array vals

        clazz = get_item_type
        items = Array.new

        if vals.is_a? Array

          i = 0
          vals.each { |val|
            resource = to_resource clazz, val
            items[i] = resource
            i = i + 1
          }

        end

        items

      end

    end


    class Page

      attr_reader :offset, :limit, :items

      def initialize offset, limit, items
        @offset = offset
        @limit = limit
        @items = items
      end

    end

  end
end

