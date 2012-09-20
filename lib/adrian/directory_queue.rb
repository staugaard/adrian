require 'adrian/queue'
require 'fileutils'

module Adrian
  class DirectoryQueue < Queue
    class Item < QueueItem

      attr_reader :path

      def initialize(path, created_at = nil)
        @path = path
      end

      def value
        path
      end

      def name
        File.basename(path)
      end

      def ==(other)
        name == other.name
      end

      def move(destination)
        destination_path = File.join(destination, File.basename(path))
        File.rename(path, destination_path)
        @path = destination_path
      end

      def updated_at
        return nil if !exist?
        File.mtime(path).utc
      end

      def created_at
        File.mtime(path).utc
      end

      def touch(updated_at = Time.new)
        File.utime(updated_at, updated_at, path)
      end

      def exist?
        File.exist?(path)
      end

    end

    def self.create(options = {})
      queue = new(options)
      FileUtils.mkdir_p(queue.available_path)
      FileUtils.mkdir_p(queue.reserved_path)
      queue
    end

    attr_reader :available_path, :reserved_path

    def initialize(options = {})
      @available_path = options.fetch(:available_path)
      @reserved_path  = options.fetch(:reserved_path, default_reserved_path)
    end

    def pop
      items.each do |item|
        return item if reserve(item)
      end

      nil
    end

    def push(value)
      item = wrap_item(value)
      item.move(@available_path)
      item.touch
      self
    end

    def include?(value)
      item = wrap_item(value)
      items.include?(item)
    end

    def reserved?(value)
      item = wrap_item(value)
      reserved_items.include?(item)
    end

    protected

    def wrap_item(value)
      value.is_a?(Item) ? value : Item.new(value)
    end

    def reserve(item)
      item.move(@reserved_path)
      item.touch
      true
    rescue Errno::ENOENT => e
      false
    end

    def items
      files.map { |file| Item.new(file) }.sort_by(&:updated_at)
    end

    def reserved_items

    end

    def files
      Dir.glob("#{@available_path}/*").select { |file| File.file?(file) }
    end

    def default_reserved_path
      File.join(File.dirname(@available_path), 'cur')
    end

  end
end
