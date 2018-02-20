require 'mixins/provision'

class ProvisionFstabSetup
  include Genesis::Framework::Task

  init do
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']
    
    # This only works for setting up basic configs right now... no fancy
    # raid 5 or 1 or anything sorry unless this gets a bit more complex.
    # If that is needed look into ZFS and the tooling around that since I
    # remember seeing some real cool stuff that you can just give some block
    # devices to and it magically sets it up in the asked for RAID config.
    
    root_uuid = run_cmd("sudo blkid /dev/sda1 -s UUID -o value").strip
    swap_uuid = run_cmd("sudo blkid /dev/sda2 -s UUID -o value").strip

    erb_file = File.read "templates/#{distro}_fstab.erb"
    template = ERB.new(erb_file).result binding
    Mixins::Provision.write_string_to_chroot(template, "/etc/fstab")
  end

end
