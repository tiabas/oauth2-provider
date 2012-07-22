module OAUTH2
  module Server
    module AccessTokenMethods

      # to_hsh
      def to_hsh
        {
          :token => token,
          :token_type => token_type,
          :expires_in => expires_in,
          :refresh_token => refresh_token
        }
      end

  end
end