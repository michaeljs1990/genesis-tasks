# dell bmc firmware version 
Facter.add(:bmc_firmware_version) do
  setcode do
    vendor = Facter.value(:manufacturer)
    case vendor
    when /dell/i
      # Make sure ipmitool is installed so we don't throw nasty errors
      `yum install -y ipmitool`
      bmc_firmware_version = Facter::Util::Resolution.exec("/usr/bin/ipmitool mc info | sed -n '/Firmware Revision/p' | tr -d [:space:] | cut -d':' -f2")
      bmc_firmware_version.strip
    end
  end
end

