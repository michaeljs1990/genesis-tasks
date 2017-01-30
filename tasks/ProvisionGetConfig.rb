class ProvisionGetConfig
  include Genesis::Framework::Task

  run do
    config_url = config[:genesis_tasks][:provision_get_config][:config_url] + "/#{facter['asset_tag']}"
    log "Downloading asset config from #{config_url}"
    open('/var/run/genesis/provision.json', 'wb') do |file|
      file << open(config_url).read
    end
  end

end

