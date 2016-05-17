module RmpdImager
  module Actions
    class PrepareImage
      property vanilla : String | Nil
      property distribution : String | Nil
      property login : String | Nil
      property server_password : String | Nil
      property rmpd_password : String | Nil
      property root_password : String | Nil
      property server_url : String | Nil
      getter :new_image_path, :image_mountpoint

      def initialize(@vanilla, @distribution, @server_url, @login, @server_password, @rmpd_password, @root_password = nil)
        time = Time.now.to_s("%d%m%Y%H%M%S").dup
        @new_image_path =   "/tmp/_#{login}_#{time}.imager"
        @image_mountpoint = "/tmp/_#{login}_#{time}.mountpoint"
      end

      def call
        logger.within("copy vanilla image to #{new_image_path}") do
          FileUtils.copy(vanilla, new_image_path)
        end

        image = Image.new(new_image_path)
        logger.within("mount image #{new_image_path} to #{image_mountpoint}") do
          image.mount(2, image_mountpoint)
        end

        logger.within("set hostname to #{login}") do
          Hostname.new(image_mountpoint).change(login)
        end

        logger.within("set passwords") do
          password = Password.new(image_mountpoint)
          if root_password
            password.change("root", root_password)
            logger.write("root password: #{root_password}")
          end
          password.change("rmpd", rmpd_password)
          logger.write("rmpd password: #{rmpd_password}")
        end

        logger.within("install rmpd") do
          rmpd = Rmpd.new(image_mountpoint, distribution)
          rmpd.remove
          rmpd.install
          rmpd.set_login(login)
          rmpd.set_password(server_password)
          logger.write("login: #{login}")
          logger.write("password: #{server_password}")
          if server_url
            logger.write("server url: #{server_url}")
            rmpd.set_server_url(server_url)
          end
        end

        logger.within("umount image") do
          image.umount
        end
      end

      def logger
        Logger.instance
      end
    end
  end
end
