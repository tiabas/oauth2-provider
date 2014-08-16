module OAuth2Provider
  module Strategy
    class Implicit < Base

      def access_token(opts={})
        @adapter.generate_access_token(@request, opts) 
      end
    end
  end
end