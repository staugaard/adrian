$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

$stdout.sync = true

require 'adrian'

class ExampleError < RuntimeError; end

class Worker < Adrian::Worker
  def work
    raise ExampleError if item.value > 0.5
  end
end




q  = Adrian::ArrayQueue.new
q2 = Adrian::ArrayQueue.new

dispatcher = Adrian::Dispatcher.new

dispatcher.on_failure(ExampleError) do |item, worker, exception|
  puts "FAILURE!!! #{item.value}"
  q2.push(item)
end

dispatcher.on_done do |item, worker|
  puts "DONE!!! #{item.value}"
end




Thread.new do
  while true
    sleep(0.1)
    q.push(rand)
  end
end

dispatcher.start(q, Worker)
