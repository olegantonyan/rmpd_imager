require "secure_random"

module RmpdImager
  module Actions
    class NewImage
      getter login : String, rmpd_password : String, root_password : String, server_password : String, server_url : String

      def initialize
        @login = SecureRandom.hex[0..6]
        @rmpd_password = SecureRandom.hex[1..8]
        @root_password = SecureRandom.hex[2..9]
        @server_password = SecureRandom.hex[3..15]
        @server_url = "https://server.slon-ds.ru"
      end

      def call
      end
    end
  end
end
