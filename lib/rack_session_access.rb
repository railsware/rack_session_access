module RackSessionAccess
  autoload :Middleware, 'rack_session_access/middleware'

  class << self
    # session resource path
    attr_accessor :path

    # session resource edit path
    attr_accessor :edit_path

    # encode session hash to string
    def encode(hash)
      [Marshal.dump(hash)].pack('m')
    end

    # decode string to session hash
    def decode(string)
      Marshal.load(string.unpack('m').first)
    end

    def configure
      yield self
    end
  end
end

RackSessionAccess.configure do |config|
  config.path      = '/rack_session'
  config.edit_path = '/rack_session/edit'
end
