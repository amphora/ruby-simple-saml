require 'builder'
require 'securerandom'

module SimpleSaml
    class SamlResponse 
        include SimpleSaml::XMLSecurity

        def initialize(saml_request: nil, principal: nil, assertion_consumer_service_url: nil, issuer: nil, sign_assertion: true, audience: nil)

            @saml_request = saml_request
            @assertion_consumer_service_url = saml_request&.assertion_consumer_service_url || assertion_consumer_service_url

            @issuer = saml_request&.issuer || issuer
            @assertion = SimpleSaml::Assertion.new(saml_request: saml_request, 
                                                principal: principal,
                                                assertion_consumer_service_url:  @assertion_consumer_service_url,
                                                issuer: @issuer,
                                                audience: audience,
                                                sign: true)

        end

        def build
            response_attributes = {
                "xmlns:samlp" => "urn:oasis:names:tc:SAML:2.0:protocol",
                "xmlns:saml" => "urn:oasis:names:tc:SAML:2.0:assertion",
                ID: "_#{SecureRandom.uuid}",
                Version: "2.0",
                IssueInstant: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
                Destination: @assertion_consumer_service_url
            }
            response_attributes["InResponseTo"] = @saml_request.id if @saml_request
        
            builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
                xml['samlp'].Response(response_attributes) do
                    xml['saml'].Issuer SimpleSaml.config.entity_id
                    xml['samlp'].Status do
                        xml['samlp'].StatusCode(Value: "urn:oasis:names:tc:SAML:2.0:status:Success")
                    end
                end
            end
            assertion = @assertion.build
            assertion_doc = Nokogiri::XML(assertion)

            builder.doc.root.add_child(assertion_doc.root)
            builder.doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
        end

        def encode 
            # Initialize a new Deflate object with BEST_COMPRESSION and no zlib header
            deflater = Zlib::Deflate.new(Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS)
            deflated_xml = deflater.deflate(self.build, Zlib::FINISH)
            deflater.close

            base64_encoded_xml = Base64.strict_encode64(deflated_xml)

            if defined?(Rails)
                base64_encoded_xml # assume rails will handle encoding
            else
                CGI.escape(base64_encoded_xml)
            end
        end

        
    end
end