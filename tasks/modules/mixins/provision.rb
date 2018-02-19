module Mixins
  module Provision
    
    CHROOT_PATH = '/mnt/chroot'

    def self.write_string_to_file(str, file)
      File.open(file, 'w') do |fd|
        fd.write(str)
      end
    end

    def self.write_string_to_chroot(str, file)
      write_string_to_file(str, CHROOT_PATH + file)
    end

  end
end

