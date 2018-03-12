require 'mixins/provision'

class ProvisionKernelSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']

    if distro == "bionic"
      # No lts is out for this yet so we have to install the latest version available
      Mixins::Provision.chroot_apt_install ["linux-generic"]
    else
      Mixins::Provision.chroot_apt_install ["linux-generic-lts-#{distro}"]
    end
  end

end
