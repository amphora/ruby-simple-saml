# frozen_string_literal: true

require_relative "simple_saml/version"


module SimpleSaml
    require "simple_saml/assertion"
    require 'simple_saml/configurator'
    require 'simple_saml/xml_security'
    require 'simple_saml/saml_request'


    class Error < StandardError; end
    # Your code goes here...

    def self.config
        @config ||= SimpleSaml::Configurator.new
      end
    
    def self.configure
        yield config
    end
    
    def consume_saml_request

    end

end
