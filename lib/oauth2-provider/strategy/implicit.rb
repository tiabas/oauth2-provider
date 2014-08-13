module OAuth2Provider
  module Grant
    class Implicit < Base

      def access_token(opts={})
        @adapter.generate_access_token(@request, opts) 
      end
    end
  end
end