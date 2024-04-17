require 'securerandom'
require 'nokogiri'
require 'httparty'



module SimpleSaml
  class Configurator


    attr_accessor :x509_certificate
    attr_accessor :private_key
    attr_accessor :entity_id
    attr_accessor :sso_endpoint
    attr_accessor :slo_endpoint
    attr_accessor :name_id_format
    attr_accessor :want_signed_requests
    attr_accessor :organisation_name
    attr_accessor :organisation_display_name
    attr_accessor :organisation_url
    attr_accessor :xml_lang
    attr_accessor :service_providers
    attr_accessor :logger

    def initialize(service_providers = [])
        base_path = File.expand_path('../../..', __FILE__) # Adjust the path as necessary
        cert_path = File.join(base_path, 'config', 'certificates', 'cs_cert.crt')
        key_path = File.join(base_path, 'config', 'certificates', 'cs_pk.key')

        # IdP Credentials
        self.x509_certificate = File.read(cert_path)
        self.private_key = File.read(key_path) 

        #

        # defaults for the metadata
        self.entity_id = "SimpleSamlIdP"
        self.sso_endpoint = "http://simplesaml/saml"
        self.slo_endpoint = nil
        self.name_id_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        self.want_signed_requests = true

        # Organisation Details
        self.organisation_name = "SimpleSaml"
        self.organisation_display_name = "Simple Saml IdP"
        self.organisation_url = "https://simplesaml.co.uk"
        self.xml_lang = "en-GB"

        self.logger = defined?(::Rails) ? Rails.logger : ->(msg) { puts msg }

        # We expec
    end

    def get_sp_metadata(sp_entity_id)
      sp = self.service_providers.find { |provider| provider[:entity_id] == sp_entity_id }
      
      if sp
        # TODO: We should be able to fetch this from a persisted store instead of making the request every time
        metadata_xml_str = fetch_sp_metadata(sp[:metadata_url])
        # This should probably be in some global constant somewhere
        namespaces = {
          'md' => 'urn:oasis:names:tc:SAML:2.0:metadata',
          'ds' => 'http://www.w3.org/2000/09/xmldsig#'
        }

        doc = Nokogiri::XML(metadata_xml_str)

        attributes = {}
        # We're using these localname based xpaths because it seems as if different metadata files use different namespace conventions
        attributes[:signing_certificate] = doc.at_xpath("//*[local-name()='KeyDescriptor' and @use='signing']/*[local-name()='KeyInfo']/*[local-name()='X509Data']/*[local-name()='X509Certificate']/text()").to_s
        attributes[:acs_post_location] = doc.at_xpath("//*[local-name()='AssertionConsumerService' and @Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location").to_s

        attributes
      else
        raise Error, "Could not find Service Provider: #{sp_entity_id}"
      end
    end

    private

    def fetch_sp_metadata(url)
      response = HTTParty.get(url)
      if response.success?
        response.body
      else
        raise Error, "Failed to fetch SP metadata from #{url}"
      end
  end
    
  end
end
