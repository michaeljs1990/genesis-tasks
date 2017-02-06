require 'mixins/config'

class ProvisionDebootstrap
  include Genesis::Framework::Task

  init do
    install :rpm, "debootstrap"
    @task_conf = config[:genesis_tasks][:provision_debootstrap]

    debootstrap_url = @task_conf[:debootstrap_rpm]
    log "Downloading debootstrap from #{debootstrap_url}"
    open('/tmp/debootstrap.rpm', 'wb') do |file|
      file << open(debootstrap_url).read
    end

    log 'Check if debootstrap is already installed'
    system('rpm -q debootstrap')
    if $?.exitstatus != 0
      log 'Installing debootstrap'
      install :rpm, '/tmp/debootstrap.rpm'
    end

    @provision_config = Mixins::Config.fetch
  end

  run do
    p @provision_config
  end

end

