require 'erb'
require 'mixins/provision'

class ProvisionPuppetSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']

    # Installing puppet this way will not give you a system wide ruby install keeping
    # the base OS super clean.
    Mixins::Provision.chroot_cmd "wget https://apt.puppetlabs.com/puppet5-release-xenial.deb"
    Mixins::Provision.chroot_cmd "dpkg -i puppet5-release-xenial.deb"
    Mixins::Provision.chroot_cmd "apt update"
    Mixins::Provision.chroot_apt_install ["puppet-agent"]

    # Install gems that are needed for my puppet code to run. In the future move this
    # to be a list that can be passed in via config values.
    Mixins::Provision.chroot_cmd " /opt/puppetlabs/puppet/bin/gem install -N collins_auth"
    Mixins::Provision.chroot_cmd " /opt/puppetlabs/puppet/bin/gem install -N librarian-puppet"
  end

end
