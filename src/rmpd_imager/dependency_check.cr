module RmpdImager
  class DependencyCheck
    class MissingDependencyError < Exception; end
    class NonRootUserError < Exception; end

    def self.call(executable, params, suggestion = nil)
      txt = "'#{executable}' is not installed or inaccessable"
      txt += " (#{suggestion})" unless suggestion.nil?
      raise MissingDependencyError.new(txt) if `#{executable} #{params}`.empty?
    end

    def self.only_root!
      raise NonRootUserError.new("must be run as root") unless `echo $EUID`.strip.to_i == 0
    end
  end
end
