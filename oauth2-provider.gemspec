lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'oauth2-provider/version'
require 'date'

Gem::Specification.new do |spec|

  spec.name             = 'oauth2-provider'
  spec.date             = Date.today.to_s
  spec.summary          = 'OAuth2 server-side wrapper'
  spec.description      = 'A ruby wrapper for handling serverside OAuth2 requests'
  spec.authors          = ['Kevin Mutyaba', 'Nick Campbell']
  spec.homepage         = ''
  spec.files            = `git ls-files`.split("\n")
  spec.require_path     = ['lib']
  spec.email            = %q{tiabasnk@gmail.com}
  spec.licenses         = ['MIT']
  spec.version          = OAuth2Provider::Version

  spec.required_rubygems_version = '>= 1.3'

  spec.cert_chain       = ['certs/tiabas-public.pem']
  spec.signing_key      = File.expand_path("~/.gem/certs/private_key.pem") if $0 =~ /gem\z/

  spec.add_dependency 'addressable', '~> 2.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov', '~> 0.7'
end