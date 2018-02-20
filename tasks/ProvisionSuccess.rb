class ProvisionSuccess
  include Genesis::Framework::Task
  run do
    collins.set_status!(facter['asset_tag'], :provisioned, "Moving to provisioned", :running)
    log "Shutting down machine..."
    run_cmd '/sbin/shutdown', '-h', 'now'
    log "Sleeping waiting for shutdown"
    sleep
  end
end

