require "inifile"

module RmpdImager
  class ConfigFile
    property :path, :data

    def initialize(@path)
      @data = IniFile.load(File.read(path)) || {} of String => Hash(String, String)
    end

    def [](key)
      data[key]
    end

    def save
      content = ""
      data.each do |k, v|
        content += "[#{k}]\n"
        v.each do |kk, vv|
          content += "#{kk} = #{vv}\n"
        end
        content += "\n"
      end
      File.write(path, content)
    end
  end
end
