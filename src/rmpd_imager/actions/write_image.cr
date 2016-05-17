module RmpdImager
  module Actions
    class WriteImage
      class Error < Exception; end

      property image_path  : String | Nil
      property disk_path : String | Nil
      property check_partitions_numbers : Array(Int32)
      property expand_partition_number : Int32
      getter disk : ::RmpdImager::Disk

      def initialize(@image_path, @disk_path, @check_partitions_numbers = [2], @expand_partition_number = 2)
        raise Error.new("no disk path given") if disk_path.nil? || disk_path.not_nil!.empty?
        raise Error.new("no image path given") if image_path.nil? || image_path.not_nil!.empty?
        dsk = Disks.new.find { |d| d.path == disk_path }
        raise Error.new("no such disk #{disk_path}") if dsk.nil?
        @disk = dsk.not_nil!
      end

      def call
        logger.within("write image #{image_path} to #{disk.path}") do
          logger.write(disk.write_image(image_path))
        end

        logger.within("expand partition") do
          logger.write(disk.expand_partition(expand_partition_number))
        end

        logger.within("check filesystem") do
          check_partitions_numbers.each do |i|
            logger.write(disk.checkfs(i))
          end
        end
      end

      def logger
        Logger.instance
      end
    end
  end
end
