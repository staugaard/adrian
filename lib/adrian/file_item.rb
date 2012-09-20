module Adrian
  class FileItem < QueueItem

    def path
      value
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
      @value = destination_path
    end

    def updated_at
      File.mtime(path).utc if exist?
    end

    def touch(updated_at = Time.new)
      File.utime(updated_at, updated_at, path)
    end

    def exist?
      File.exist?(path)
    end

  end
end
