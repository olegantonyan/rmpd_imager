module RmpdImager
  module Actions
    class ListAll
      def call
        logger.within("fetch all created images data") do
          result = Db::Remote.new.fetch_all
          logger.write("login | server_url | server_password | rmpd_password | root_password | created_at")
          result.each do |i|
            logger.write("#{i["login"]} | #{i["server_url"]} | #{i["server_password"]} | #{i["rmpd_password"]} | #{i["root_password"]} | #{i["created_at"]}")
          end
        end
      end

      def logger
        Logger.instance
      end
    end
  end
end
