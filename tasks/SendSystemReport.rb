require 'open-uri'

class SendSystemReport
  include Genesis::Framework::Task

  description "Send Lshw info to collins"
  # hold all yml config for this task
  @task_conf = [] 

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
    @task_conf = config[:genesis_tasks][:send_system_report]

    log 'Installing nokogiri for XML parsing'
    install :gem, 'nokogiri'

    lldpd_url = @task_conf[:lldp_rpm]
    log "Installing lldpctl from #{lldpd_url}"
    open('/tmp/lldp.rpm', 'wb') do |file|
      file << open(lldpd_url).read
    end


    log 'Installing lshw and lldpd'
    install :rpm, 'lshw', '/tmp/lldp.rpm'

    log 'Starting up lldpd so we can call lldpctl'
    run_cmd "systemctl", "start", "lldpd"
  end

  run do
    # LLDP information is sometimes not returned fast enough causing
    # intake to fail. When this happens only this block of code is 
    # run again. Placing a sleep here to ensure it doesn't just run 3
    # times quickly and actually gives a bit of a cool down so lldp
    # has time to be returned.
    sleep 30
    # require nokogiri now since we are guranteed to have it
    require 'nokogiri'

    # get string of xml and verify that we have had
    # valid xml returned to us by marashaling it into
    # Nokogiri XML
    lshw_report = self.generate_lshw_report
    lshw_xml = Nokogiri::XML lshw_report
   
    lldp_report = self.generate_lldp_report
    # special case for testing environment
    lldp_report = self.generate_fake_lldp_report if @task_conf[:no_tor_switch]
    lldp_xml = Nokogiri::XML lldp_report

    # Send report to collins so it's useful to us 
    # Put collins in maintenance mode so we can submit this report
    # then switch it back to the original state.
    asset = collins.get(facter['asset_tag'])
    final_status = asset.status

    log "Submitting LSHW report"
    if not  collins.set_multi_attribute! facter['asset_tag'], {
      :lshw => lshw_xml.to_xml, 
      :lldp => lldp_xml.to_xml,
      :CHASSIS_TAG => facter['asset_tag']}

      log "Unable to submit LSHW and LLDP report"
      return 1
    end
  end

  def self.generate_lldp_report
    begin
      run_cmd 'lldpctl', '-f', 'xml'
    rescue => e
      log "Failed to run lshw. Error: #{e.message}"
      raise e
    end
  end

  def self.generate_lshw_report
    begin
      run_cmd '/usr/sbin/lshw', '-quiet', '-xml'
    rescue => e
      log "Failed to run lshw. Error: #{e.message}"
      raise e
    end
  end

  # useful in environments like a home lab where
  # you may not have a TOR switch setup and only
  # have a single router on the network. 
  def self.generate_fake_lldp_report
    log 'Generating fake LLDP report'
    return %{<?xml version="1.0" encoding="UTF-8"?>
      <lldp label="LLDP neighbors">
       <interface label="Interface" name="#{@task_conf[:interface_name]}" via="LLDP" rid="1" age="0 day, 00:18:25">
        <chassis label="Chassis">
         <id label="ChassisID" type="mac">#{@task_conf[:chassis_id]}</id>
         <name label="SysName">#{@task_conf[:sys_name]}</name>
         <descr label="SysDescr">#{@task_conf[:sys_descr]}</descr>
         <capability label="Capability" type="Router" enabled="on"/>
        </chassis>
        <port label="Port">
         <id label="PortID" type="local">616</id>
         <descr label="PortDescr">ge-0/0/7.0</descr>
         <mfs label="MFS">1514</mfs>
         <auto-negotiation label="PMD autoneg" supported="no" enabled="yes">
          <advertised label="Adv" type="1Base-T" hd="no" fd="yes"/>
          <current label="MAU oper type">unknown</current>
         </auto-negotiation>
        </port>
        <vlan label="VLAN" vlan-id="#{@task_conf[:vlan_id]}" pvid="yes">#{@task_conf[:vlan_name]}</vlan>
        <lldp-med label="LLDP-MED">
         <device-type label="Device Type">Network Connectivity Device</device-type>
        </lldp-med>
       </interface>
      </lldp>}
  end

end
