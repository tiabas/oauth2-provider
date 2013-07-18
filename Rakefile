$LOAD_PATH << File.dirname(__FILE__) + '/lib'

require 'oauth2-provider'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
end

desc "Run tests"
task :default => :test
