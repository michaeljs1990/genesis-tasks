require 'erb'
require 'mixins/provision'

class ProvisionNetworkSetup
  include Genesis::Framework::Task

  init do
    @asset = collins.get(facter['asset_tag'])

    if not @asset.addresses.nil?
      @address = @asset.addresses.first.address
      @gateway = @asset.addresses.first.gateway
      @netmask = @asset.addresses.first.netmask
    end
    @provision_config = Mixins::Config.fetch
  end

  condition "asset has an IP address" do
    is_set = true
    is_set = false if @address.nil?
    is_set
  end

  condition "asset has a gateway address" do
    is_set = true
    is_set = false if @gateway.nil?
    is_set
  end

  condition "asset has a netmask address" do
    is_set = true
    is_set = false if @netmask.nil?
    is_set
  end

  run do
    # This is custom to xenial for right now. It should have a
    # nice clean abstraction placed around it later.
    distro = @provision_config['os']['distro']
    erb_file = File.read "templates/#{distro}_interfaces.erb"
    primary_interface = get_interface
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/network/interfaces.d/default")
  end

  def self.get_interface
    install :rpm, "biosdevname"
    run_cmd("biosdevname -i eth0").strip
  end

end