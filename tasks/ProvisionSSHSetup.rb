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
    distro = @provision_config['os']['distro']

    Mixins::Provision.chroot_apt_install ["openssh-server"]
    Mixins::Provision.chroot_cmd "echo root:#{@password} | chpasswd"

    # Setup the sshd config
    erb_file = File.read "templates/#{distro}_sshd_config.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/ssh/sshd_config")
  end

end
