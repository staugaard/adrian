require_relative 'test_helper'
require 'tempfile'
require 'tmpdir'
require 'fileutils'

describe Adrian::RotatingDirectoryQueue do
  before do
    @root_path = Dir.mktmpdir('dir_queue_test')
    @q = Adrian::RotatingDirectoryQueue.create(:path => @root_path)
  end

  after do
   FileUtils.rm_r(@root_path, :force => true)
  end

  describe 'pop' do
    it 'only provides files available in the current time-stamped directory' do
      @item1 = Adrian::FileItem.new(Tempfile.new('item1').path)
      @item2 = Adrian::FileItem.new(Tempfile.new('item2').path)
      @item3 = Adrian::FileItem.new(Tempfile.new('item3').path)

      Time.stub(:now, Time.now) do
        todays_directory    = File.join(@root_path, Time.now.strftime('%Y-%m-%d'))
        tomorrows_directory = File.join(@root_path, (Time.now + 60 * 60 * 24).strftime('%Y-%m-%d'))

        FileUtils.mkdir_p(todays_directory)
        FileUtils.mkdir_p(tomorrows_directory)

        @item1.move(todays_directory)
        @item2.move(tomorrows_directory)
        @item3.move(@root_path)

        @q.pop.must_equal @item1
        @q.pop.must_be_nil
      end
    end
  end

  describe 'push' do
    before do
      @item = Adrian::FileItem.new(Tempfile.new('item').path)
    end

    it 'moves the file to the time-stamped available directory' do
      Time.stub(:now, Time.now) do
        original_path = @item.path
        @q.push(@item)

        assert_equal false, File.exist?(original_path)
        assert_equal true,  File.exist?(File.join(@q.available_path, @item.name))

        @item.path.must_equal File.join(@root_path, Time.now.strftime('%Y-%m-%d'), @item.name)
      end
    end
  end

end
