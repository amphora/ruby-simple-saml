# frozen_string_literal: true

require_relative "simple_saml/version"


module SimpleSaml
    require 'simple_saml/xml_security'
    require "simple_saml/assertion"
    require 'simple_saml/configurator'
    require 'simple_saml/saml_request'
    require 'simple_saml/saml_response'

    class Error < StandardError; end
    # Your code goes here...

    def self.config
        @config ||= SimpleSaml::Configurator.new
      end
    
    def self.configure
        yield config
    end
    
    def self.generate_metadata_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.instruct!(:xml, version: "1.0", encoding: "UTF-8")
        
        xml = builder.EntityDescriptor("xmlns" => "urn:oasis:names:tc:SAML:2.0:metadata",
                                       "entityID" => self.config.entity_id) do |entity_descriptor|
            entity_descriptor.IDPSSODescriptor("protocolSupportEnumeration" => "urn:oasis:names:tc:SAML:2.0:protocol", "WantAuthnRequestsSigned"=>self.config.want_signed_requests.to_s) do |idp_sso_descriptor|
                idp_sso_descriptor.KeyDescriptor("use" => "signing") do |key_descriptor|
                key_descriptor.ds(:KeyInfo, "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#") do |key_info|
                    key_info.ds(:X509Data) do |x509_data|
                    x509_data.ds(:X509Certificate, self.config.x509_certificate.strip)
                    end
                end
                end
                
                idp_sso_descriptor.NameIDFormat(self.config.name_id_format)
                
                idp_sso_descriptor.SingleSignOnService("Binding" => "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
                                                    "Location" => self.config.sso_endpoint)
                
                # Include SingleLogoutService if slo_endpoint is provided
                if self.config.slo_endpoint
                    idp_sso_descriptor.SingleLogoutService("Binding" => "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
                                                            "Location" => self.config.slo_endpoint)
                end
            end

            entity_descriptor.Organisation() do |organisation|
                organisation.OrganisationName(self.config.organisation_name, "xml:lang"=>self.config.xml_lang)
                organisation.OrganisationDisplayName(self.config.organisation_display_name, "xml:lang"=>self.config.xml_lang)
                organisation.OrganisationUrl(self.config.organisation_url, "xml:lang"=>self.config.xml_lang)
            end
        end
        
        xml
    end

end
