require 'mixins/provision'

class ProvisionInitramfsSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    Mixins::Provision.chroot_cmd "update-initramfs -u -k all"
  end

end
