require 'fileutils'

module Adrian
  class DirectoryQueue < Queue
    include Filters

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
      filters << Filters::FileLock.new(:duration => options[:lock_duration], :reserved_path => reserved_path)
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

    protected

    def wrap_item(value)
      value.is_a?(FileItem) ? value : FileItem.new(value)
    end

    def reserve(item)
      item.move(@reserved_path)
      item.touch
      true
    rescue Errno::ENOENT => e
      false
    end

    def items
      items = files.map { |file| FileItem.new(file) }
      items.reject! { |item| filter?(item) }
      items.sort_by(&:updated_at)
    end

    def files
      Dir.glob("{#{@available_path}, #{@reserved_path}}/*").select { |file| File.file?(file) }
    end

    def default_reserved_path
      File.join(File.dirname(@available_path), 'cur')
    end

  end
end
