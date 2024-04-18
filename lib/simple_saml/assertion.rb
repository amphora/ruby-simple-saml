require 'builder'
require 'securerandom'

module SimpleSaml
    class Assertion
        include SimpleSaml::XMLSecurity

        attr_reader :issuer, :user, :audience, :authn_context_class_ref

        def initialize(principal:, issuer: nil, audience: nil, 
                       assertion_consumer_service_url: nil, assertion_audience: nil, saml_request: nil, sign: false)

            # @issuer = saml_request&.issuer || issuer
            @principal = principal
            @audience = saml_request&.provider_name || saml_request&.issuer || issuer
            @assertion_consumer_service_url = saml_request&.assertion_consumer_service_url || assertion_consumer_service_url
            @sign = sign

            
        end
        
        def raw(include_declaration: false)
            # Build the SAML assertion XML document
            # if !nameid_getter
            #     raise "NameID getter not defined for the Assertion"
            # end
            # nameid = nameid_getter.call(@principal)

            nameid = SimpleSaml.config.nameid_getter&.call(@principal) || "email@email.com"


            # We will need to validate all of these inputs
            now = Time.now.utc
            builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
                xml.Assertion(ID: "_#{SecureRandom.uuid}", 
                            IssueInstant: now.strftime("%Y-%m-%dT%H:%M:%SZ"), 
                            Version: "2.0", 
                            xmlns: "urn:oasis:names:tc:SAML:2.0:assertion") do

                    xml.Issuer SimpleSaml.config.entity_id
                    xml.Subject do
                        # So far we only support the email address format
                        xml.NameID nameid, Format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
                        xml.SubjectConfirmation(Method: "urn:oasis:names:tc:SAML:2.0:cm:bearer") do
                            xml.SubjectConfirmationData NotOnOrAfter: (now + 5 * 60).strftime("%Y-%m-%dT%H:%M:%SZ"), Recipient: @assertion_consumer_service_url
                        end
                    end
                    xml.Conditions NotBefore: now.strftime("%Y-%m-%dT%H:%M:%SZ"), NotOnOrAfter: (now + 5 * 60).strftime("%Y-%m-%dT%H:%M:%SZ") do
                        xml.AudienceRestriction do
                            xml.Audience @audience
                        end
                    end
                    xml.AuthnStatement AuthnInstant: now.strftime("%Y-%m-%dT%H:%M:%SZ") do
                        xml.AuthnContext do
                            xml.AuthnContextClassRef "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
                        end
                    end
                    xml.AttributeStatement do
                        xml.Attribute(Name: "emailAddress", NameFormat: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic") do
                            xml.AttributeValue nameid # So far nameid is the email address, so this is ok for now
                        end
                    end
                    # This needs to be properly defined
                    # xml.AuthzDecisionStatement(Decision: "Permit", Resource: "https://resource.example.com") do
                    #     xml.Action "Read", Namespace: "urn:oasis:names:tc:SAML:1.0:action:rwedc"
                    # end
                end
            end

            builder.doc
        end

        def build
            if @sign
                sign_assertion(self)
            else
                self.raw
            end
        end
    end
end
