require "file"

module FileUtils
  class Error < Exception; end

  def self.copy(src, dst, force = true)
    raise Error.new("source file #{src} does not exists") if src.nil? || src.not_nil!.empty? || !File.exists?(src.not_nil!)
    raise Error.new("destination file not given") if dst.nil? || dst.not_nil!.empty?
    raise Error.new("destination file #{dst} already exists and force is false") if File.exists?(dst) && !force
    `cp #{src} #{dst} #{force ? "-f" : ""}`
  end
end
