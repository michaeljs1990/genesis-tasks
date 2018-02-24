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
    erb_file = File.read "templates/#{distro}_hosts.erb"

    hostname_fqdn = @hostname
    hostname = hostname_fqdn.split(".").first

    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/hosts")

    Mixins::Provision.chroot_cmd "hostname #{hostname_fqdn}"
  end

end