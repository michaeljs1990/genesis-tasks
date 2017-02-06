require 'json'

module Mixins
  module Config
    
    CONF_FILE_PATH = '/var/run/genesis/provision.json'

    def self.fetch
      file = File.read(CONF_FILE_PATH)
      return JSON.parse(file)
    end

  end
end

