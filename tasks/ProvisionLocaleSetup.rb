require 'mixins/provision'

class ProvisionLocaleSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']
    locale = "en_US.UTF-8"

    Mixins::Provision.chroot_cmd "dpkg-reconfigure -f noninteractive locales"
    Mixins::Provision.chroot_cmd "locale-gen #{locale}"
    Mixins::Provision.chroot_cmd "update-locale LANG=#{locale}"
  end

end
