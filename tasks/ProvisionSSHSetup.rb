require 'mixins/provision'

class ProvisionSSHSetup
  include Genesis::Framework::Task

  init do
    @asset = collins.get(facter['asset_tag'])
    @password = @asset.PASSWORD
    @provision_config = Mixins::Config.fetch
  end

  condition "asset has a password" do
    is_set = true
    is_set = false if @password.nil?
    is_set
  end

  run do
    Mixins::Provision.chroot_apt_install ["openssh-server"]
    Mixins::Provision.chroot_cmd "echo root:#{@password} | chpasswd"
  end

end
