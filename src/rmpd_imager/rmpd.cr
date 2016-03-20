module RmpdImager
  class Rmpd
    class Error < Exception; end

    property :root_path, :distribution_path

    def initialize(@root_path, @distribution_path)
      raise Error.new("cannot operate on / or empty path") if root_path.nil? || root_path.not_nil!.empty? || root_path == "/"
      raise Error.new("no distribution path given") if distribution_path.nil? || distribution_path.not_nil!.empty?
      DependencyCheck.call("tar", "--version")
      DependencyCheck.call("cp", "--version")
      DependencyCheck.call("find", "--version")

    end

    def config_file
      "rmpd.conf"
    end

    def rmpd_client_path
      rmpd_home_path + "/rmpd_client"
    end

    def rmpd_home_path
      root_path + "/home/rmpd"
    end

    def config_file_path
      rmpd_client_path + "/rmpd.conf"
    end

    def example_config_file_path
      rmpd_client_path + "/rmpd.conf.example"
    end

    def install
      `tar -xf #{distribution_path} -C #{rmpd_home_path}`
    end

    def remove
      raise Error.new("rmpd client path is / or empty") if rmpd_client_path.nil? || rmpd_client_path.not_nil!.empty? || rmpd_client_path == "/"
      `find #{rmpd_client_path}/* | grep -v "#{config_file}$" | xargs rm -rf`
    end

    def set_login(login)
      raise Error.new("no login given") if login.nil? || login.not_nil!.empty?
      create_config_file_if_needed
      cfg = ConfigFile.new(config_file_path)
      cfg["remote_control"]["login"] = login.not_nil!
      cfg.save
    end

    def set_password(password)
      raise Error.new("no password given") if password.nil? || password.not_nil!.empty?
      create_config_file_if_needed
      cfg = ConfigFile.new(config_file_path)
      cfg["remote_control"]["password"] = password.not_nil!
      cfg.save
    end

    def set_server_url(url)
      raise Error.new("no url given") if url.nil? || url.not_nil!.empty?
      create_config_file_if_needed
      cfg = ConfigFile.new(config_file_path)
      cfg["remote_control"]["server_url"] = url.not_nil!
      cfg.save
    end

    private def create_config_file_if_needed
      `cp #{example_config_file_path} #{config_file_path}` unless File.exists?(config_file_path)
    end
  end
end
