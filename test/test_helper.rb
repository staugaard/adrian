require 'bundler/setup'

begin
  require 'debugger'
rescue LoadError => e
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'adrian'

require 'minitest/autorun'
require 'timecop'
