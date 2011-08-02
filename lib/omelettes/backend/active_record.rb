module Omelettes
  module Backend
    class ActiveRecord
      def persist(object, attributes)
        attributes.each do |name, value|
          object.update_attribute(name, value)
        end
      end
      
      def complete(model)
      end
    end
  end
end
