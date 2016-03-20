module RmpdImager
  class Disks
    include Enumerable(Disk)

    def initialize
      DependencyCheck.call("lsblk", "--version", "may be found in 'util-linux package'")
      raw_output = `lsblk  --nodeps --noheadings --paths --list --output NAME,SIZE,RM,MODEL`
      @raw_disks = raw_output.split("\n").select { |i| i.size > 0 }
    end

    def each
      @raw_disks.each do |i|
        yield Disk.new(i)
      end
    end

    def removable
      select { |i| i.removable }
    end
  end

  class Disk
    class Error < Exception; end

    property :path, :size, :removable, :model

    def initialize(raw_disk)
      DependencyCheck.only_root!
      DependencyCheck.call("e2fsck", "-V 2>&1")
      DependencyCheck.call("resize2fs", "--help 2>&1")
      DependencyCheck.call("parted", "--help")
      arr = raw_disk.split(" ").reject { |i| i.size == 0 }
      @path = arr[0]
      @size = arr[1]
      @removable = arr[2] == "0" ? false : true
      @model = arr[3..-1].join(" ")
    end

    def write_image(image_path)
      DependencyCheck.call("dd", "--version")
      check_removable!
      `dd if=#{image_path} of=#{path}; sync`
    end

    def expand_partition(partition_number)
      check_removable!
      checkfs(partition_number)
      `parted -l; parted #{path} resize #{partition_number} #{size_parted}; sync`
      checkfs(partition_number)
      `resize2fs #{partition_path(partition_number)}; sync`
    end

    def checkfs(partition_number)
      check_removable!
      `e2fsck -f #{partition_path(partition_number)} -y; sync`
    end

    private def partition_path(partition_number)
      "#{path}#{partition_number}"
    end

    private def size_parted
      raw = `parted #{path} print`.strip
      lines = raw.split("\n").select { |i| i.size > 0 }
      lines[1].split(":")[1].strip
    end

    private def check_removable!
      raise Error.new("cannot operate on non-removable disk #{path}") unless removable
    end
  end
end
