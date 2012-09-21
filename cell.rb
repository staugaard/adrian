require 'celluloid'

class Worker
  include Celluloid

  def work(i)
    sleep(1)
    puts "-#{i}-"
  end
end

pool = Worker.pool(:size => 10)

puts pool.inspect

(1..100).each do |i|
  pool.work!(i)
end

sleep(10)
