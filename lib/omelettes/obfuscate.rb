module Omelettes
  class Obfuscate
    class << self
      def cook(silent=false)
        total_tables = 0
        total_attributes = 0
        Words.load(word_list || "/usr/share/dict/words")
        backend = (self.backend || Backend::ActiveRecord).new
        
        tables.each do |table|
          next if ignore_table?(table)
          print "\nProcessing #{model(table).name}" unless silent
          model(table).find_each do |object|
            new_attributes = {}
            model(table).columns.each do |column|
              next if ignore_column?(column.name) || column.type != :string
              
              if new_value = object.obfuscate_value(column.name)
                new_attributes[column.name] = new_value
                total_attributes += 1
              end
            end
            print "." unless silent
            backend.persist(object, new_attributes)
          end
          total_tables += 1
          backend.complete(model(table))
        end
        print "\n" unless silent
        [total_tables, total_attributes]
      end

      def tables
        ActiveRecord::Base.connection.tables
      end

      def model(table)
        self.models ||= {}
        self.models[table] ||= table.camelcase.singularize.constantize
        self.models[table]
      end

      def ignore_table?(table)
        ignore_tables.each do |ignore|
          return true if table.match(ignore).to_s == table
        end
        false
      end

      def ignore_column?(column)
        ignore_columns.each do |ignore|
          return true if column.match(ignore).to_s == column
        end
        false
      end

      def obfuscate(string)
        return nil if string.nil?
        result = []
        string.split(/(\s+)|([[:punct:]])/).each do |word|
          result << (word.match(/[a-zA-Z]+/).nil? ? word : Words.replace(word))
        end
        result.join("")
      end

      attr_accessor :ignore_tables
      attr_accessor :ignore_columns
      attr_accessor :word_list
      attr_accessor :models
      attr_accessor :backend
    end
  end
end