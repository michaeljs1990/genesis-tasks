require 'mixins/config'
require 'mixins/provision'

class ProvisionSetEnv
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']

    if distro == "bionic"
      # Properly set path so everything else works how one would expect. If you don't
      # set this the path uses the same one from the host system.
      Mixins::Provision.chroot_cmd "echo '. /etc/environment' >> /root/.bashrc"
    end
  end

end
