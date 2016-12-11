module Logging
  module Collins

    def self.collins
      Genesis::Framework::Utils.collins
    end

    def self.facter
      Genesis::Framework::Utils.facter
    end

    def self.log message
      begin
        t = facter['asset_tag']
        if t
          collins.log! t, message
        end
      rescue => e
        puts "Error logging to Collins asset #{t}: #{e.message}"
      end
    end
  end
end
