module OAuth2
  module OAuth2Error
    class TemporarilyUnavailable < OAuth2::OAuth2Error::Error
    	def initialize
	    	super
	    	@code = 401 
    	end
    end
  end
end