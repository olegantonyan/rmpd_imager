module RmpdImager
  class Hostname
    class Error < Exception; end

    property :root_path

    def initialize(root_path)
      raise Error.new("cannot operate on / or empty path") if root_path.nil? || root_path.empty? || root_path == "/"
      @root_path = root_path
    end

    def change(new_hostname)
      File.write(hostname_file_path, new_hostname)
    end

    def hostname_file_path
      root_path + "/etc/hostname"
    end
  end
end
