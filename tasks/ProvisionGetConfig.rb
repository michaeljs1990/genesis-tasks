require 'mixins/config'

class ProvisionGetConfig
  include Genesis::Framework::Task

  run do
    config_url = config[:genesis_tasks][:provision_get_config][:config_url] + "/#{facter['asset_tag']}"
    log "Downloading asset config from #{config_url}"
    open(Mixins::Config::CONF_FILE_PATH, 'wb') do |file|
      file << open(config_url).read
    end
  end

end

