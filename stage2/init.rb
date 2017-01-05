#! /usr/bin/env ruby

# localisms for bootstrapping genesis.  See genesis-bootstrap for the
# environment that this runs in.

# The following code assumes our working directory is GENESIS_ROOT

require "rubygems"
require "yaml"
require "retryingfetcher"
require "promptcli"

# support outputing some debugging info
def runcmd cmd
  puts 'running: ' + cmd
  Kernel.system cmd
end

# no buffering of stdout so we see messages immediately
$stdout.sync = true

genesis_mode = ENV['GENESIS_MODE']
puts "Stage2 starting.  genesis_mode: '#{genesis_mode}'"

@genesis_config = {}
begin
  cfile = ENV['GENESIS_CONF']
  puts '', "loading Genesis config file '#{cfile}'"
   @genesis_config = YAML::load( File.read(cfile) )
rescue => e
  # genesis-bootstrap has already parsed this so the contents must be good
  raise %q|reading genesis conf file '%s'  failed: %s| % \
    [cfile, e.message]
end

puts "\nEnsuring temp directory for downloads exists"
Dir.mkdir("tmp", 0755) unless File.directory? "tmp"
Dir.mkdir("/root/repo", 0755) unless File.directory? "/root/repo"
Dir.mkdir("/root/repo/gems", 0755) unless File.directory? "/root/repo/gems"

puts ''
# protect against funny configs
unless @genesis_config.fetch(:gems, nil).nil?
  @genesis_config.fetch(:gems).each do |gem, flags|
    puts 'Installing %s gem...' % [gem]
    runcmd  ['gem install', gem, flags].reject {|e| e.nil?}.join(' ')
    if $?.exitstatus != 0
      raise 'gem install exited with status: ' + $?.exitstatus.to_s 
    end
  end
end

puts "\nInstalling repo files"
unless @genesis_config.fetch(:yum_repos, nil).nil?
  @genesis_config.fetch(:yum_repos, []).each do |name, params|
    puts "    #{name}"
    File.open("/etc/yum.repos.d/#{name}.repo", 'w') do |file|
      file.puts params[:label]
      params.reject {|k| k == :label}.each do |k,v|
        puts "        #{k}  #{v}" # DEBUG
        file.puts "#{k} = #{v}"
      end
    end
  end
end

raise 'ERROR: no tasks_url specified in configuration' \
  if @genesis_config.fetch(:tasks_url, nil).nil?
puts "\nDownloading tasks package..."
Genesis::RetryingFetcher.get(@genesis_config[:tasks_url]) do |data|
  File.open('tmp/tasks.tgz', 'w', 0755) { |file| file.write data }
end

puts "\nExtracting tasks..."
Kernel.system('tar',  '-xzvf', 'tmp/tasks.tgz')

puts "\nStarting genesis #{genesis_mode}"
system('genesis', genesis_mode)

puts '', 'Stage2 all done!'
