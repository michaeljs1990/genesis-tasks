class UtilReportStartup
  include Genesis::Framework::Task

  run do
    ip_addr = `hostname -I`

    log 'Asset has started up in util mode'
    log "Genesis is listening on port 22 @ #{ip_addr}" 
  end
end
