require_relative 'test_helper'
require 'tempfile'

describe Adrian::FileItem do
  before do
    @item = Adrian::FileItem.new(Tempfile.new('file_item_test').path)
  end

  it 'aliases value as path' do
    item = Adrian::FileItem.new('path/a')
    assert_equal 'path/a', item.value
  end

  it 'has a name from the path' do
    item = Adrian::FileItem.new('path/name.ext')
    assert_equal 'name.ext', item.name
  end

  it 'is equal to another item when they have the same name' do
    item1 = Adrian::FileItem.new('path/a')
    item2 = Adrian::FileItem.new('path/b')
    assert(item1 != item2)

    item3 = Adrian::FileItem.new('path/a')
    assert_equal item1, item3
  end

  describe 'move' do
    before do
      @destination = Dir.mktmpdir('file_item_move_test')
    end

    it 'moves the file to the given directory' do
      @item.move(@destination)
      assert_equal true, File.exist?(File.join(@destination, @item.name))
    end

    it 'updates the path to its new location' do
      @item.move(@destination)
      assert_equal @destination, File.dirname(@item.path)
    end

  end

  describe 'touch' do

    it 'changes the update timestamp to the current time' do
      now = Time.now - 100
      Time.stub(:new, now) { @item.touch }

      assert_equal now.to_i, @item.updated_at.to_i
    end

  end

  it 'exists when the file at the given path exists' do
    assert_equal true, @item.exist?
    File.unlink(@item.path)

    assert_equal false, @item.exist?
  end

end
