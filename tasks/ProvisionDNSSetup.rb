require 'erb'
require 'mixins/provision'

class ProvisionDNSSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']
    erb_file = File.read "templates/#{distro}_resolv.conf.erb"

    dns_server = "8.8.8.8"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/resolv.conf")
  end

end
