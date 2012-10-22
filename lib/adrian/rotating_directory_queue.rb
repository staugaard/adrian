require 'adrian/directory_queue'
require 'fileutils'

module Adrian

  class RotatingDirectoryQueue < DirectoryQueue
    attr_reader :time_format

    def initialize(options = {})
      super
      @time_format = options.fetch(:time_format, '%Y-%m-%d')
    end

    def available_path
      path = "#{super}/#{Time.now.strftime(time_format)}"

      if path != @previous_avaliable_path
        FileUtils.mkdir_p(path)
        @previous_avaliable_path = path
      end

      path
    end
  end
end
