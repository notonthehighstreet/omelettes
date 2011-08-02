begin
  require 'active_record'
rescue LoadError
  require 'activerecord' unless defined?(ActiveRecord)
end

require 'omelettes/column'
require 'omelettes/model_additions'
require 'omelettes/obfuscate'
require 'omelettes/words'
require 'omelettes/backend/active_record'
require 'omelettes/backend/bulk'

module Omelettes
  require 'omelettes/railtie' if defined?(Rails)

  def self.setup
    Omelettes::Obfuscate.models = {}
    yield Omelettes::Obfuscate
  end
end