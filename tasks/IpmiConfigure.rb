class IpmiConfigure
  include Genesis::Framework::Task

  description "Configure the IPMI console"

  precondition "Make sure IPMI is started" do
    # It should be safe to assume that the device is
    # always registered under ipmi0 on genesis.
    exists = File.exist?('/dev/ipmi0')
    log "IPMI was not started for configuration" if !exists
    exists
  end

  run do
    # Grab the asset from collins for configuration with ipmitool
    asset = collins.find({'TAG' => facter['asset_tag']}).first
    ipmi = asset.ipmi

    begin
      run_cmd 'ipmitool lan set 1 ipsrc static'
    rescue => e
      log 'Unable to set ip source for ipmi as static'
      raise e
    end
    
    begin
      run_cmd "ipmitool lan set 1 ipaddr #{ipmi.address}"
    rescue => e
      log "Unable to set ipmi console IP to #{ipmi.address}"
      raise e
    end

    begin
      run_cmd "ipmitool lan set 1 netmask #{ipmi.netmask}"
    rescue => e
      log "Unable to set ipmi console netmask to #{ipmi.netmask}"
      raise e
    end
  end

end
