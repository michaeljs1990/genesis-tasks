require 'erb'
require 'mixins/provision'

class ProvisionHostnameSetup
  include Genesis::Framework::Task

  init do
    @asset = collins.get(facter['asset_tag'])
    @hostname = @asset.HOSTNAME
    @provision_config = Mixins::Config.fetch
  end

  condition "asset has a hostname" do
    is_set = true
    is_set = false if @hostname.nil?
    is_set
  end

  run do
    distro = @provision_config['os']['distro']

    hostname_fqdn = @hostname
    hostname = hostname_fqdn.split(".").first

    erb_file = File.read "templates/#{distro}_hosts.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/hosts")

    erb_file = File.read "templates/#{distro}_hostname.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/hostname")

    # hostnamectl needs dbus running for whatever reason... cool.
    Mixins::Provision.chroot_cmd "systemctl start dbus"
    Mixins::Provision.chroot_cmd "hostnamectl set-hostname #{hostname_fqdn}"
    Mixins::Provision.chroot_cmd "systemctl stop dbus"
  end

end
