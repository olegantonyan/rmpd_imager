module RmpdImager
  module Actions
    class SubmitNew
      property :submit
      getter :local_file

      def initialize(@submit)
        @local_file = "rmpd.db.scv"
      end

      def call(*args)
        logger.within("save new image data to local file #{local_file}") do
          db = Db.new(local_file)
          logger.write db.add(*args)
        end

        if submit
          remote = Db::Remote.new
          logger.within("submit new image data to rmpd_database") do
            result = remote.submit(*args)
            logger.write(result)
          end
        end
      end

      def logger
        Logger.instance
      end
    end
  end
end
