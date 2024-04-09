require 'securerandom'

module SimpleSaml
  class Configurator
    attr_accessor :x509_certificate
    attr_accessor :private_key
    attr_accessor :password
    attr_accessor :algorithm

    attr_accessor :logger

    def initialize
        base_path = File.expand_path('../../..', __FILE__) # Adjust the path as necessary
        cert_path = File.join(base_path, 'config', 'certificates', 'certificate.crt')
        key_path = File.join(base_path, 'config', 'certificates', 'private_key.pem')

        self.x509_certificate = File.read(cert_path)
        self.private_key = File.read(key_path) 

        self.logger = defined?(::Rails) ? Rails.logger : ->(msg) { puts msg }
    end

    
  end
end
