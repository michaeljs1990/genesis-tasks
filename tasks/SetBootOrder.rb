class SetBootOrder
  include Genesis::Framework::Task

  description "Configure the boot order with the IPMI console"

  precondition "Make sure IPMI is started" do
    # It should be safe to assume that the device is
    # always registered under ipmi0 on genesis.
    exists = File.exist?('/dev/ipmi0')
    log 'IPMI is not running' if !exists
    exists
  end

  run do
    # https://ma.ttwagner.com/ipmi-trick-set-the-boot-device/
    
    begin
      run_cmd "ipmitool chassis bootdev pxe options=persistent"
    rescue => e
      log 'Failed to set the boot order'
      raise e
    end

  end

end

