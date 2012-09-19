require_relative 'test_helper'

describe Adrian::ArrayQueue do
  it 'should allow construction with an array' do
    q = Adrian::ArrayQueue.new([1,2,3])
    q.pop.must_equal 1
    q.pop.must_equal 2
    q.pop.must_equal 3
    q.pop.must_be_nil
  end

  it 'should allow construction without an array' do
    q = Adrian::ArrayQueue.new
    q.pop.must_be_nil
  end

  it 'should act as a queue' do
    q = Adrian::ArrayQueue.new

    q.push(1)
    q.push(2)
    q.push(3)

    q.pop.must_equal 1
    q.pop.must_equal 2
    q.pop.must_equal 3
    q.pop.must_be_nil
  end
end
