require 'bundler/setup'

require 'debugger'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'adrian'

require 'minitest/autorun'
