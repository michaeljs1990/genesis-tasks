# Reference Links for this fix
# https://communities.intel.com/thread/87759
# http://serverfault.com/questions/775980/disable-internal-intel-x710-lldp-agent

class HardwareIntelX710Config
  include Genesis::Framework::Task

  # Device and Vendor IDs can be found in the link
  # below I have only added the devices I tested on although
  # everything in the X710/XL710 line can likely be added
  # http://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/xl710-10-40-controller-spec-update.pdf
  precondition 'has Intel XL710 Device' do
    bad_interfaces = get_intel_x710_devices
    bad_interfaces.any?
  end

  init do
    # Mount debugfs so we are able to interact with hardware controls
    system 'mountpoint /sys/kernel/debug'
    run_cmd 'mount -t debugfs none /sys/kernel/debug' if $?.exitstatus == 1
  end

  run do
    # Turn off LLDP which the devices above handle at the hardware level and do
    # not pass to the host OS completely breaking our intake process. Thanks Intel!
    bad_interfaces = get_intel_x710_devices
    bad_interfaces.each do |iface|
      driver = File.basename File.readlink("/sys/class/net/#{iface}/device/driver/module")
      version = File.basename File.readlink("/sys/class/net/#{iface}/device")
      if driver == 'i40e'
        log "#{iface}: X710 NIC configured to no longer eat LLDP packets"
        run_cmd "echo lldp stop > /sys/kernel/debug/#{driver}/#{version}/command"
      end
    end
  end

  def self.get_interfaces
    run_cmd("ls /sys/class/net | grep -v 'lo'").lines
  end

  def self.get_intel_x710_devices
    bad_interface = []
    interfaces = get_interfaces
    intel_vendor_id = '0x8086'
    known_bad_devices = ['0x1584', '0x1583']
    interfaces.each do |iface|
      iface = iface.strip
      vendor_id = ''
      if File.exists?("/sys/class/net/#{iface}/device/vendor")
        vendor_id = File.read("/sys/class/net/#{iface}/device/vendor").strip
      end
      device_id = File.read("/sys/class/net/#{iface}/device/device").strip
      if (vendor_id == intel_vendor_id) && known_bad_devices.include?(device_id)
        bad_interface << iface
      end
    end
    bad_interface
  end

end
