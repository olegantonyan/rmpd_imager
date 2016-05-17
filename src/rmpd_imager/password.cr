module RmpdImager
  class Password
    class Error < Exception; end

    property root_path : String | Nil

    def initialize(@root_path)
      DependencyCheck.call("openssl", "version")
      raise Error.new("cannot operate on / or empty path") if root_path.nil? || root_path.empty? || root_path == "/"
    end

    def change(username, new_password)
      raise Error.new("no username given") if username.nil? || username.not_nil!.empty?
      raise Error.new("no new password given") if new_password.nil? || new_password.not_nil!.empty?
      shadow_file = File.read(shadow_file_path).split("\n").reject { |i| i.empty? }
      line = shadow_file.find { |i| username == i.split(':').first }
      raise Error.new("user #{username} not fount in shadow file") unless line
      new_shadow_file = shadow_file.reject { |i| i == line }
      line_array = line.split(':')
      line_array[1] = hashed(new_password)
      new_shadow_file << line_array.join(':')
      File.write(shadow_file_path, new_shadow_file.join('\n'))
    end

    def shadow_file_path
      root_path.not_nil! + "/etc/shadow"
    end

    private def hashed(passwd)
      salt = ""
      1.upto(16) do
        salt += ('a'..'z').to_a.sample
      end
      `openssl passwd -1 -salt #{salt} #{passwd}`.delete("\n")
    end
  end
end
