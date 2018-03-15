module Mixins
  module Provision
    # include for run_cmd method
    include Genesis::Framework::Task

    CHROOT_PATH = '/mnt/chroot'

    def self.write_string_to_file(str, file)
      File.open(file, 'w') do |fd|
        fd.write(str)
      end
    end

    def self.write_string_to_chroot(str, file)
      write_string_to_file(str, CHROOT_PATH + file)
    end

    def self.chroot_apt_install packages
      pkg = packages.join " "
      run_cmd("chroot #{CHROOT_PATH} env -i bash -l -c 'DEBIAN_FRONTEND=noninteractive apt install -y #{pkg}'")
    end

    def self.chroot_cmd cmd
      run_cmd("chroot #{CHROOT_PATH} env -i bash -l -c '#{cmd}'")
    end

  end
end
