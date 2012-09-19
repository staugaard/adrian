require 'adrian/queue'
require 'fileutils'

module Adrian
  class DirectoryQueue < Queue

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
      files.each do |file|
        reserved_file = reserve(file)
        return reserved_file if reserved_file
      end

      nil
    end

    def push(file)
      touch(file)
      available_file_path = File.join(@available_path, File.basename(file))
      File.rename(file, available_file_path)
      available_file_path
    end

    protected

    def files
      Dir.glob("#{@available_path}/*").select { |file| File.file?(file) }
    end

    def default_reserved_path
      File.join(File.dirname(@available_path), 'cur')
    end

    def reserve(file)
      reserved_file_path = File.join(@reserved_path, File.basename(file))
      File.rename(file, reserved_file_path)
      touch(reserved_file_path)
      reserved_file_path
    rescue Errno::ENOENT => e
      false
    end

    def touch(path)
      File.utime(Time.new, Time.new, path)
    end

  end
end
