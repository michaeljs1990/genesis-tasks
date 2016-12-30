class ProvisionGetConfig
  include Genesis::Framework::Task

  precondition "has asset tag?" do
    not facter['asset_tag'].nil?
  end

  precondition "asset tag doesn't exist in collins?" do
    t = facter['asset_tag']
    log "Checking for #{t} in collins..."
    exists = collins.exists?(t)
    log "Asset #{t} not found in collins!" if !exists
    !exists
  end

  run do
    begin
      collins.create!(facter['asset_tag'], :generate_ipmi => true)
    rescue Collins::RequestError => e
      if e.code == 409
        log "Asset %s already exists in collins" % facter['asset_tag']
      else
        log "Error trying to create asset in collins. Message: %s" % e.message
        raise e
      end
    end
  end
end

