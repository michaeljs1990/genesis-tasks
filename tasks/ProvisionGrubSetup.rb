require 'mixins/provision'

class ProvisionGrubSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    # don't hard code this in the future. Also support more
    # than my basic disk config... that comes latter though.
    Mixins::Provision.chroot_cmd "grub-install -v /dev/sda"
    Mixins::Provision.chroot_cmd "update-grub"
  end

end
