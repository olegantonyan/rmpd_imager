require "ini"

module RmpdImager
  class ConfigFile
    property path : String | Nil
    property data : Hash(String, Hash(String, String))

    def initialize(@path)
      @data = INI.parse(File.read(path)) || {} of String => Hash(String, String)
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
      File.write(path.not_nil!, content)
    end
  end
end
