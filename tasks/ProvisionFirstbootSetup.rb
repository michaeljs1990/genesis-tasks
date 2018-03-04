require 'erb'
require 'mixins/provision'

class ProvisionFirstbootSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']
    repo = @provision_config['puppet'][distro]['repo']
    path = @provision_config['puppet'][distro]['path']

    Mixins::Provision.chroot_cmd "apt update"
    Mixins::Provision.chroot_apt_install ["git"]

    # This is a bit hacky, I'm not sure what is all not getting setup for 
    # ruby when it's inside a chroot but the following is needed in order
    # for librarian-puppet to properly install the modules.... This will
    # get cleaned up later after i start writting the first boot script
    # and figure out what is going on. For whatever reason gemhome when
    # placed in the .gemrc file isn't read when loading gems so I haven't
    # been able to get this working without manually setting GEM_HOME...
    binary_dir = '/opt/puppetlabs/puppet/bin/'
    librarian = '/opt/puppetlabs/puppet/bin/librarian-puppet'
    gemhome = 'GEM_HOME=/opt/puppetlabs/puppet/lib/ruby/gems/2.4.0'
    Mixins::Provision.chroot_cmd "rm -rf #{path}"
    Mixins::Provision.chroot_cmd "git clone #{repo} #{path}"
    Mixins::Provision.chroot_cmd "cd #{path} && #{gemhome} PATH=$PATH:/opt/puppetlabs/bin #{librarian} install"

  end

end
