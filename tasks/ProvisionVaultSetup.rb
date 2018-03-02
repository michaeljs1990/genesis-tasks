require 'erb'
require 'mixins/provision'

# Place the vault token needed for
# puppet to run successfully.
class ProvisionVaultSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    token = @provision_config['vault_token']
    distro = @provision_config['os']['distro']

    # Replace with config param to make switching this out easy
    Mixins::Provision.chroot_cmd "echo #{token} > /root/.vault_token"
  end

end
