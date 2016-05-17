require "csv"
require "http/client"
require "json"

module RmpdImager
  class Db
    property file_path : String

    def initialize(@file_path)
    end

    def add(login, server_url, server_password, rmpd_password, root_password)
      csv = CSV.build { |csv| csv.row(login, server_url, server_password, rmpd_password, root_password) }
      File.open(file_path, "a") do |file|
        file << csv
      end
      csv
    end

    class Remote
      class Error < Exception; end

      def initialize
        @login = "rmpd"
        @password = "ihateyou"
        @addr = "rmpddatabase.slon-ds.ru"
        @port = 443
        @ssl = true
      end

      def fetch_all
        response = client.get("/devices.json")
        raise Error.new("fetch error #{response.status_code}") unless response.status_code == 200
        JSON.parse(response.body)
      end

      def submit(login, server_url, server_password, rmpd_password, root_password)
        data = { login:            login,
                 server_url:       server_url,
                 server_password:  server_password,
                 rmpd_password:    rmpd_password,
                 root_password:    root_password }
        headers = HTTP::Headers.new
        headers.add("Content-Type", "application/json")
        response = client.post("/devices.json", body: data.to_json, headers: headers)
        raise Error.new("submit error #{response.status_code} #{response.body}") unless response.status_code == 201
        response.body
      end

      private def client
        client = HTTP::Client.new(@addr, @port, @ssl)
        client.basic_auth(@login, @password)
        client
      end
    end
  end
end
