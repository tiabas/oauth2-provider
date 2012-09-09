module OAuth2
  module Client
    class Connection
      require 'uri'

        attr_reader :scheme, :host, :method 
        
        def initialize(scheme, host, method, opts={})
          @scheme = opts[:scheme] || "https"
          @host = host
          @params = params
          @method = opts[:method] || "post"
        end
        
        def scheme=(scheme)
          unless ['http', 'https'].include? scheme
            raise "The scheme #{scheme} is not supported. Only http and https are supported"
          end
          @scheme = scheme
        end
    end 
  end           
end
