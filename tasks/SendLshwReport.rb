class SendLshwReport
  include Genesis::Framework::Task

  description "Send Lshw info to collins"

  precondition "has asset tag?" do
    not facter['asset_tag'].nil?
  end

  precondition "asset tag exists in collins" do
    t = facter['asset_tag']
    log "Checking for #{t} in collins..."
    exists = collins.exists?(t)
    log "Asset #{t} not found in collins!" if !exists
    exists
  end

  init do
    # install nokogiri for parsing XML returned
    # from lshw.
    install :gem, 'nokogiri'

    log "Installing lshw"
    install :rpm, "lshw"
  end

  run do
    # require nokogiri now since we are guranteed to have it
    require 'nokogiri'

    # get string of xml and verify that we have had
    # valid xml returned to us by marashaling it into
    # Nokogiri XML
    lshw_report = self.generate_lshw_report
    lshw_xml = Nokogiri::XML lshw_report
   
    # Send report to collins so it's useful to us 
    success = collins.set_multi_attribute! facter['asset_tag'], { 
      :lshw => lshw_xml.to_xml, 
      :CHASSIS_TAG => facter['asset_tag']}
    log 'Reporting lshw to collins failed on set_multi_attribute' if not success
  end

  def self.generate_lshw_report
    begin
      run_cmd "/usr/sbin/lshw", "-quiet", "-xml"
    rescue => e
      log "Failed to run lshw. Error: #{e.message}"
      raise e
    end
  end

end
