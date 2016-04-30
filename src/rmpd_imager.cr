require "colorize"
require "option_parser"

require "./rmpd_imager/*"
require "./rmpd_imager/actions/*"
require "../lib/*"

unless ARGV.size > 0
  STDERR.puts "use --help to see available options".colorize(:yellow)
  #exit(1)
end

options = {} of Symbol => String
OptionParser.new do |opt|
  opt.on("-h",                  "--help",                         "show this message")                                 { puts opt; exit(0) }
  opt.on("-v",                  "--version",                      "show version")                                      { puts RmpdImager::VERSION; exit(0) }
  opt.on("-n",                  "--new",                          "create brand new image")                            { |v| options[:new] = "true" }
  opt.on("-s SERVER_PASSWORD",  "--server-password=PASSWORD",     "server password to set (see --login)")              { |v| options[:server_password]  = v }
  opt.on("-i VANILLA",          "--vanilla-image=VANILLA",        "path to vanilla image")                             { |v| options[:vanilla]  = v }
  opt.on("-d DISTRIBUTION",     "--distribution=DISTRIBUTION",    "path to archive with rmpd")                         { |v| options[:distribution]  = v }
  opt.on("-p PASSWORD",         "--rmpd-password=PASSWORD",       "rmpd's password to set")                            { |v| options[:rmpd_password]  = v }
  opt.on("-r ROOT_PASSWORD",    "--root-password=PASSWORD",       "root's password to set")                            { |v| options[:root_password]  = v }
  opt.on("-l LOGIN",            "--login=LOGIN",                  "server login to set")                               { |v| options[:login]  = v }
  opt.on("-w DISK",             "--write-to-disk=DISK",           "disk device where to write an image")               { |v| options[:disk]  = v }
  opt.on("-u URL",              "--server-url=URL",               "server url")                                        { |v| options[:server_url]  = v }
  opt.on("-a",                  "--list-all",                     "just show all created images")                      { |v| options[:list_all]  = "true" }
  opt.on("-S",                  "--submit",                       "submit new device to the server")                   { |v| options[:submit]  = "true" }
  opt.on("-t",                  "--three-partiotion",             "image with rootfs and another separate partition")  { |v| options[:three]  = "true" }
end.parse!

RmpdImager.main(options)

module RmpdImager
  def self.main(opts)
    run(opts)
    exit(0)
  rescue e : Exception
    STDERR.puts "#{e.class.name}: #{e}".colorize(:red)
    e.backtrace.each do |f|
      STDERR.puts "#{f}".colorize(:yellow)
    end
    exit(1)
  end

  def self.run(opts)
    if opts.fetch(:list_all, nil)
      list = Actions::ListAll.new
      list.call
      return
    end
    if opts.fetch(:new, nil)
      nw = Actions::NewImage.new
      opts[:login] =            opts.fetch(:login, nil)           || nw.login
      opts[:server_password] =  opts.fetch(:server_password, nil) || nw.server_password
      opts[:rmpd_password] =    opts.fetch(:rmpd_password, nil)   || nw.rmpd_password
      opts[:root_password] =    opts.fetch(:root_password, nil)   || nw.root_password
      opts[:server_url] =       opts.fetch(:server_url, nil)      || nw.server_url
    end

    pre = Actions::PrepareImage.new(opts.fetch(:vanilla, nil),
                                    opts.fetch(:distribution, nil),
                                    opts.fetch(:server_url, nil),
                                    opts.fetch(:login, nil),
                                    opts.fetch(:server_password, nil),
                                    opts.fetch(:rmpd_password, nil),
                                    opts.fetch(:root_password, nil))
    pre.call

    if opts.fetch(:disk, nil)
      wr = if opts.fetch(:three)
             Actions::WriteImage.new(pre.new_image_path, opts[:disk], [2, 3], 3)
           else
             Actions::WriteImage.new(pre.new_image_path, opts[:disk])
           end
      wr.call
    end

    Actions::SubmitNew.new(opts.fetch(:submit, nil)).call(opts[:login], opts[:server_url], opts[:server_password], opts[:rmpd_password], opts[:root_password])
  end
end
