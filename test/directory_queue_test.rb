require_relative 'test_helper'
require 'tempfile'
require 'tmpdir'

describe Adrian::DirectoryQueue do
  before do
    @q = Adrian::DirectoryQueue.create(:available_path => Dir.mktmpdir('dir_queue_test'))
  end

  it 'should act as a queue for files' do
    file1 = Tempfile.new('item1')
    file2 = Tempfile.new('item2')
    file3 = Tempfile.new('item3')

    @q.push(file1)
    @q.push(file2)
    @q.push(file3)

    File.basename(@q.pop).must_equal File.basename(file1)
    File.basename(@q.pop).must_equal File.basename(file2)
    File.basename(@q.pop).must_equal File.basename(file3)
    @q.pop.must_be_nil
  end

  describe 'file backend' do

    describe 'pop' do
      before do
        @file = Tempfile.new('item')
      end

      it 'provides an available file' do
        @q.push(@file.path)
        assert @q.pop
      end

      it 'moves the file to the available directory' do
        @q.push(@file.path)
        @q.pop

        assert_equal false, File.exist?(@file.path)
        assert_equal true,  File.exist?(File.join(@q.reserved_path, File.basename(@file.path)))
      end

      it 'updates the file modification time' do
        @q.push(@file.path)
        original_updated_at = Time.new - 10_000
        new_path = File.join(@q.available_path, File.basename(@file.path))
        File.utime(original_updated_at, original_updated_at, new_path)
        assert_equal original_updated_at.to_i, File.mtime(new_path).to_i
        @q.pop
        reserved_path = File.join(@q.reserved_path, File.basename(@file.path))

        assert(File.mtime(reserved_path).to_i != original_updated_at.to_i)
      end

      it 'skips the file when moved by another process' do
        def @q.files
          [ 'no/longer/exists' ]
        end
        assert_equal nil, @q.pop
      end

      it "only provides normal files" do
        not_file = Dir.mktmpdir(@q.available_path, 'directory_queue_x')
        assert_equal nil, @q.pop
      end

    end

    describe 'push' do
      before do
        @file = Tempfile.new('item')
      end

      it 'moves the file to the available directory' do
        @q.push(@file.path)

        assert_equal false, File.exist?(@file.path)
        assert_equal true,  File.exist?(File.join(@q.available_path, File.basename(@file.path)))
      end

      it 'updates the file modification time' do
        original_updated_at = Time.new - 10_000
        File.utime(original_updated_at, original_updated_at, @file.path)
        assert_equal original_updated_at.to_i, File.mtime(@file.path).to_i
        @q.push(@file.path)

        new_path = File.join(@q.available_path, File.basename(@file.path))
        assert(File.mtime(new_path).to_i != original_updated_at.to_i)
      end

    end

  end

end
