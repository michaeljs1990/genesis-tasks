require 'mixins/config'
require 'mixins/provision'

class ProvisionDebootstrap
  include Genesis::Framework::Task

  init do
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

    @chroot = Mixins::Provision::CHROOT_PATH
    @provision_config = Mixins::Config.fetch
  end

  run do
    distro = @provision_config['os']['distro']
    url = @provision_config['os']['url']
    arch = @provision_config['os']['arch']
    log "Debootstrapping #{distro} from #{url} for #{arch}"
    system("debootstrap --arch #{arch} #{distro} #{@chroot} #{url}")

    ["mount -t proc proc #{@chroot}/proc/",
     "mount -t sysfs sys #{@chroot}/sys/",
     "mount -o bind /dev #{@chroot}/dev/",
     "mount -o bind /dev/pts #{@chroot}/dev/pts"].each do |cmd|
      system "#{cmd}"
      raise "Unable to mount: #{cmd}" unless $?.success?
    end

  end

end
