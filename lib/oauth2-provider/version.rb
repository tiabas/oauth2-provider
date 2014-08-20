module OAuth2Provider
  class Version
    MAJOR = 0 unless defined? OAuth2Provider::Version::MAJOR
    MINOR = 4 unless defined? OAuth2Provider::Version::MINOR
    PATCH = 0 unless defined? OAuth2Provider::Version::PATCH

    def self.to_s
      [MAJOR, MINOR, PATCH].compact.join('.')
    end
  end
end
