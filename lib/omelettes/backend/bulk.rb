module Omelettes
  module Backend
    class Bulk
      def initialize
        @tables = {}
      end
      
      def persist(object, new_attributes)
        table_for(object.class).persist(object, new_attributes)
      end
      
      def complete(model)
        table_for(model).process(:force)
      end
      
      def table_for(model)
        @tables[model] ||= Table.new(model)
      end
      
      class Table
        class_attribute :process_limit
        self.process_limit = 1000
        
        def initialize(klass)
          @klass = klass
          @values = []
        end
        
        def persist(object, new_attributes)
          new_attributes["id"] ||= object.id
          @values << new_attributes
          process
        end
        
        def process(force = false)
          if force or @values.size >= process_limit
            @values.group_by { |h| h.keys.sort }.each do |column_names, attribute_lists|
              data = attribute_lists.map { |hash| hash_to_array(column_names, hash) }
              @klass.import(column_names, data)
            end
            @values.clear
          end
        end
        
        def hash_to_array(column_names, hash)
          hash.inject([]) do |array, (key, value)|
            index = column_names.index(key) || raise("Column not found: #{key}. Columns are #{column_names.inspect}")
            array[index] = value
            array
          end
        end
      end
    end
  end
end
