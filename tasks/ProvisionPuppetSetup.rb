require 'erb'
require 'mixins/provision'

class ProvisionPuppetSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch

    @host = @provision_config['collins']['host']
    @username = @provision_config['collins']['username']
    @password = @provision_config['collins']['password']
  end

  run do
    distro = @provision_config['os']['distro']

    # Installing puppet this way will not give you a system wide ruby install keeping
    # the base OS super clean.
    Mixins::Provision.chroot_cmd "wget https://apt.puppetlabs.com/puppet5-nightly/puppet5-nightly-release-stretch.deb"
    Mixins::Provision.chroot_cmd "dpkg -i puppet5-nightly-release-stretch.deb"
    Mixins::Provision.chroot_cmd "rm /puppet5-nightly-release-stretch.deb"
    Mixins::Provision.chroot_cmd "apt update"
    Mixins::Provision.chroot_apt_install ["puppet-agent"]

    # Setup gemrc file so that when gems are run they look in the correct location
    # just more crap to avoid installing ruby as a system dependency.
    erb_file = File.read "templates/gemrc.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/root/.gemrc")

    # Install gems that are needed for my puppet code to run. In the future move this
    # to be a list that can be passed in via config values. For whatever reason the gem
    # environment in the chroot installs to the system gem folder instead of the puppetlabs
    # gem environment. We overwrite this to try to ensure isolating everything about bootstap
    # from the running system.
    binary_dir = '/opt/puppetlabs/puppet/bin/'
    install_dir = '/opt/puppetlabs/puppet/lib/ruby/gems/2.4.0'
    Mixins::Provision.chroot_cmd "/opt/puppetlabs/puppet/bin/gem install -i #{install_dir} -n #{binary_dir} -N collins_auth"
    Mixins::Provision.chroot_cmd "/opt/puppetlabs/puppet/bin/gem install -i #{install_dir} -n #{binary_dir} -N librarian-puppet"

    # Setup config file needed for the collins auth module to talk to our collins.
    host = @host
    user = @username
    pass = @password
    erb_file = File.read "templates/collins.yml.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/collins.yml")
  end

end
