module OAuth2
  module DataStore
    class MockDataStore < Hash
      class << self; attr_reader :instances; end

      def find(attrs={})
        found = nil
        index = 0
        store = self.class.instances
        while index < store.length do
          match = true
          target = store[index] 
          attrs.each do |k, v|
            match = match & (target[k.to_sym] == v)
          end
          break if match
        end
        target
      end
    end
  end
end

require 'datastore/access_token'
require 'datastore/authorization_code'
require 'datastore/client_application'