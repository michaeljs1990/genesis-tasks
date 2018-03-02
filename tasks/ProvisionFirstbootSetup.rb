require 'erb'
require 'mixins/provision'

class ProvisionFirstbootSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']

    Mixins::Provision.chroot_cmd "apt update"
    Mixins::Provision.chroot_apt_install ["git"]
  end

end
