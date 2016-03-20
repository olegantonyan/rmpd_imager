module RmpdImager
  class Image
    class Error < Exception; end

    property :path, :mount_point

    def initialize(@path)
      DependencyCheck.only_root!
      DependencyCheck.call("fdisk", "--version")
      DependencyCheck.call("mount", "--version")
      raise Error.new("no path given") if path.nil? || path.empty?
    end

    def mount(partition_number, point)
      ok = false
      1.upto(2) do
        ok = mount_to(point, partition_number)
        if ok
          @mount_point = point
          break
        else
          umount(point)
        end
      end
      raise Error.new("failed to mount image #{path} to #{mount_point}") if !ok || mount_point != point
    end

    def umount(point = mount_point)
      raise Error.new("no mount point given to umount") unless point
      if system("umount #{point}")
        @mount_point = nil
      else
        raise Error.new("failed to umount image #{path} from #{point}")
      end
    end

    private def mount_to(point, partition_number)
      Dir.mkdir_p(point, "666")
      system "mount -o loop,offset=#{start_sector(partition_number) * 512} #{path} #{point}"
    end

    private def start_sector(partition_number = 2)
      fdisk_output = `fdisk -l #{path}`
      parsed = fdisk_output.split("\n").reject { |i| i.empty? }
      partitions = parsed[7..-1]
      partition = partitions[partition_number - 1]
      partition.split(" ").reject { |i| i.empty? }[1].to_i
    end
  end
end
