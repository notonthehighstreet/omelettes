module Omelettes
  module ModelAdditions
    module ClassMethods
      def column_config(column_name)
        @column_config ||= {}
        @column_config[column_name.to_s]
      end
      
      def treat(column_name, style=nil, &block)
        @column_config ||= {}
        column = Column.new(column_name, style, &block)
        @column_config[column_name.to_s] = column
        column
      end
      alias :scramble :treat
      
      def ignore(column_name)
        @column_config ||= {}
        column = Column.new(column_name, :hardened)
        @column_config[column_name.to_s] = column
        column
      end
      alias :harden :ignore
    end

    def obfuscate(column_name)
      original_value = self.send(column_name)
      new_value = obfuscate_value(column_name)
      self.update_attribute(column_name, new_value) if new_value != original_value
    end
    
    def obfuscate_value(column_name)
      original_value = self.send(column_name)
      if column = self.class.column_config(column_name)
        column.process(original_value)
      else
        Column.default(column_name, original_value)
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
    end
  end
end

ActiveRecord::Base.class_eval do
  include Omelettes::ModelAdditions
end
