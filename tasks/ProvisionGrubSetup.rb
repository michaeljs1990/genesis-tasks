require 'mixins/provision'

class ProvisionGrubSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    rootdevice = '/dev/sda'
    magic_tic = "'\"'\"'"
    # don't hard code this in the future. Also support more
    # than my basic disk config... that comes latter though.
    
    Mixins::Provision.chroot_cmd "sed -i -e #{magic_tic}s/GRUB_HIDDEN_TIMEOUT=.*/# GRUB_HIDDEN_TIMEOUT=0/#{magic_tic} /etc/default/grub"
    Mixins::Provision.chroot_cmd "sed -i -e #{magic_tic}s/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/#{magic_tic} /etc/default/grub"
    Mixins::Provision.chroot_cmd "sed -i -e #{magic_tic}s/GRUB_CMDLINE_LINUX_DEFAULT=.*/# GRUB_CMDLINE_LINUX_DEFAULT=\"text\"/#{magic_tic} /etc/default/grub"
    Mixins::Provision.chroot_cmd "grub-install -v #{rootdevice}"
    Mixins::Provision.chroot_cmd "update-grub"
  end

end
