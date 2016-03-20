require "secure_random"

module RmpdImager
  module Actions
    class NewImage
      getter :login, :rmpd_password, :root_password, :server_password, :server_url

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
