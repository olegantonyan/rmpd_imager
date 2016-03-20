require "csv"

module RmpdImager
  class Db
    property :file_path

    def initialize(@file_path)
    end

    def add(login, server_url, server_password, rmpd_password, root_password)
      c = CSV.build do |csv|
            csv.row(login, server_url, server_password, rmpd_password, root_password)
          end
      File.open(file_path, "a") do |file|
        file << c
      end
    end
  end
end
