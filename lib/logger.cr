require "colorize"

class Logger
  def initialize
    puts "Started at #{Time.now}".colorize(:blue)
  end

  def self.instance
    @@instance ||= new
  end

  def within(message, &block)
    raise Exception.new("no block given") unless block
    puts "[BEGIN #{Time.now}] #{message}".colorize(:green)
    yield
    puts "[END   #{Time.now}] #{message}".colorize(:cyan)
  end

  def write(message)
    puts message
  end

  at_exit do
    puts "Finished at #{Time.now}".colorize(:blue)
  end
end
