module OAuth2
  module DataStore
    class AccessTokenDataStore < MockDataStore

      SCOPES = %w{ scope1 scope2 scope3 }
      
      private_class_method :new
      
      class << self
        include OAuth2::Helper

        def refresh(cid, ref_token)
          old_token = find_by_attributes(
                      :client_id => cid,
                      :refresh_token => ref_token,
                      :active => true
                      )
          old_token.refresh!
        end

        def create_token(cid, uid, expires_in=3600, token_type='bearer')
          self.instances ||= []
          token = new
          token.merge!({
                    :id => self.instances.length,
                    :client_id => cid,
                    :user_id => uid,
                    :token => generate_urlsafe_key,
                    :token_type => token_type,
                    :refresh_token => generate_urlsafe_key,
                    :expires_in => expires_in,
                    :active => true,
                    :updated_at => Time.now,
                    :created_at => Time.now
                  })
          
          self.instances << token
        end
      end

      def active?
        !!self[:active]
      end

      def expired?
        (self[:updated_at] + self[:expires_in]) <= Time.now
      end

      def valid?
        active? && !expired?
      end

      def deactivate!
         self[:active] = false
      end

      def refresh!
         self[:token] = generate_urlsafe_key
      end

    end
  end
end