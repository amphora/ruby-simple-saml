require 'builder'
require 'securerandom'

module SimpleSaml
    class SamlResponse 
        def initialize(saml_request:, assertion_consumer_service_url: nil, issuer: nil)

            @saml_request = saml_request
            @assertion_consumer_service_url = saml_request&.assertion_consumer_service_url || assertion_consumer_service_url

            @issuer = saml_request&.issuer || issuer
            @assertion = SimpleSaml::Assertion.new(saml_request: saml_request, 
                                                principal: nil,
                                                assertion_consumer_service_url:  @assertion_consumer_service_url,
                                                issuer: @issuer)

        end

        def build
            builder = Builder::XmlMarkup.new(indent: 2)
            builder.instruct! :xml, version: "1.0", encoding: "UTF-8"

            xml_str = builder.tag!("samlp:Response", 
                    "xmlns:samlp" => "urn:oasis:names:tc:SAML:2.0:protocol", 
                    "xmlns:saml" => "urn:oasis:names:tc:SAML:2.0:assertion", 
                    ID: "_#{SecureRandom.uuid}", 
                    Version: "2.0", 
                    IssueInstant: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), 
                    Destination: @assertion_consumer_service_url, 
                    InResponseTo: @saml_request.id ) do |response|

                response.tag!("saml:Issuer", @issuer)
                response.tag!("samlp:Status") do |status|
                    status.tag!("samlp:StatusCode", Value: "urn:oasis:names:tc:SAML:2.0:status:Success")
                end
                # Assuming @assertion#build returns a string of XML
                response << @assertion.build
            end

            doc = Nokogiri::XML(xml_str) { |config| config.default_xml.noblanks }
            pretty_xml = doc.to_xml(indent: 2)
            puts pretty_xml
        end
    end
end