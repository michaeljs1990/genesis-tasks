require 'pathname'
require 'fileutils'
require 'mixins/provision'

class ProvisionFormatDisk
  include Genesis::Framework::Task

  init do
    install :rpm, "parted", "gdisk", "mdadm"
    @asset = collins.get(facter['asset_tag'])
    @disks = @asset.disks.select {|x| x['SIZE'] > 0 }
  end

  condition "asset has supported disk configuration" do
    # Currently only have a r610 with a hardware raid that
    # reports in lshw as one disk. This is the only config
    # I am going to support until I can order some more drives.
    # We must filter by size since CD drives are reported here
    # as having a size of 0.
    true if @disks.length == 1
  end

  run do
    devices = get_devices

    devices.each do |device|
      name = device.split('/')[-1]
      # Clean the partition of any previous volumes
      # make this configurable in the future
      system "parted -s #{device} mklabel msdos"
      # Number of 512 Byte chunks available on the disk
      blocks = File.read("/sys/block/#{name}/size").to_i
      disk_size = blocks * 512

      # Create 2GiB swap partition and give the rest to root
      # should make this configurable later
      one_mib = (1024 * 1024)
      swap_size = 1024 * 1024 * 1024 * 2
      root_size = disk_size - swap_size - one_mib
      mkpart = []
      # https://www.thomas-krenn.com/en/wiki/Partition_Alignment
      # 1 MiB alignment seems to be the general advice
      mkpart << "mkpart primary ext4 1MiB #{root_size}B set 1 boot on"
      mkpart << "mkpart primary linux-swap #{root_size + one_mib}B 100%"

      # Create partion and update the partition table
      puts "Creating partitions on #{device}"
      system "parted --script --align=cyl -- #{device} #{mkpart.join(' ')} 2>&1"
      puts "Probing #{device}'s partitions"
      system "sleep 3 ; partprobe -s #{device} 2>&1"

      # TODO: Really bad assumption but using this for right now.
      # should write some helper around partitions in order to
      # properly query for the root device. Although everything
      # above is hard coded right now so it's not going to hurt
      # anything.
      system("mkfs.ext4 -L root #{device}1")
      system("mkswap -L swap #{device}2")
      mount_device("#{device}1", Mixins::Provision::CHROOT_PATH)
    end

  end

  # Return a list of all drives that should be available
  # on this machine. If these are not available something
  # has gone very wrong.
  #
  # TODO: This function should handle making sure any device that
  # we are about to return is not already mounted on the filesystem.
  # This should never happen but rerunning this script multiple
  # times without manual cleanup is very valuable for development
  # speed and also just feels cleaner.
  def self.get_devices 
    devices = []
    @disks.each_with_index do |_, index|
      drive = ('a'..'z').to_a[index]
      devices << "/dev/sd#{drive}"
    end
    return devices
  end

  def self.mount_device device, mount_point
    path = Pathname.new(mount_point)
    FileUtils.mkpath(mount_point) if not path.directory?
    run_cmd "mount #{device} #{mount_point}" if not path.mountpoint?
  end

end

