require "securerandom"
require "nokogiri"
require "httparty"

module SimpleSaml
  class Configurator
    attr_accessor :x509_certificate, :private_key, :entity_id, :sso_endpoint, :slo_endpoint, :name_id_format,
                  :want_signed_requests, :organisation_name, :organisation_display_name, :organisation_url, :xml_lang, :service_providers, :nameid_getter, :logger

    def initialize(service_providers = [])
      base_path = File.expand_path("../..", __dir__) # Adjust the path as necessary

      # IdP Credentials
      # self.x509_certificate
      # self.private_key
      # Generate private key and certificate in case none are supplied during config
      generate_key_and_certificate


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
      self.nameid_getter = nil

      # We expec
    end

    def get_sp_metadata(sp_entity_id)
      sp = service_providers.find { |provider| provider[:entity_id] == sp_entity_id }

      raise Error, "Could not find Service Provider: #{sp_entity_id}" unless sp

      # TODO: We should be able to fetch this from a persisted store instead of making the request every time
      metadata_xml_str = fetch_sp_metadata(sp[:metadata_url])
      # This should probably be in some global constant somewhere
      namespaces = {
        "md" => "urn:oasis:names:tc:SAML:2.0:metadata",
        "ds" => "http://www.w3.org/2000/09/xmldsig#"
      }

      doc = Nokogiri::XML(metadata_xml_str)

      attributes = {}
      # We're using these localname based xpaths because it seems as if different metadata files use different namespace conventions
      attributes[:signing_certificate] =
        doc.at_xpath("//*[local-name()='KeyDescriptor' and @use='signing']/*[local-name()='KeyInfo']/*[local-name()='X509Data']/*[local-name()='X509Certificate']/text()").to_s
      attributes[:acs_post_location] =
        doc.at_xpath("//*[local-name()='AssertionConsumerService' and @Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location").to_s

      attributes
    end

    def generate_key_and_certificate
      self.private_key = generate_private_key
      self.x509_certificate = generate_certificate(OpenSSL::PKey::RSA.new(private_key))
    rescue OpenSSL::OpenSSLError => e
      raise Error, "Failed to generate key and certificate: #{e.message}"
    end

    private

    def fetch_sp_metadata(url)
      response = HTTParty.get(url)
      raise Error, "Failed to fetch SP metadata from #{url}" unless response.success?

      response.body
    end

    def generate_private_key
      OpenSSL::PKey::RSA.new(2048).to_pem
    end
    
    def generate_certificate(private_key)
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2 # X.509v3
      cert.serial = SecureRandom.random_number(2**160) # Random serial number
      cert.subject = OpenSSL::X509::Name.parse("/CN=SimpleSamlIdP")
      cert.issuer = cert.subject # Self-signed
      cert.public_key = private_key.public_key
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60 # Valid for 1 year
    
      cert.sign(private_key, OpenSSL::Digest.new('SHA256'))
      cert.to_pem
    end
  end
end
