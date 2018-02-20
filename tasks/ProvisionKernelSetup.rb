require 'mixins/provision'

class ProvisionKernelSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']

    Mixins::Provision.chroot_apt_install ["linux-generic-lts-#{distro}"]
  end

end
