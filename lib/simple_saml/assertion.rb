require 'builder'
require 'securerandom'

module SimpleSaml
    class Assertion
        attr_reader :issuer, :user, :audience, :authn_context_class_ref

        def initialize(principal:, issuer: nil, audience: nil, 
            assertion_consumer_service_url: nil, nameid_getter: nil, assertion_audience: nil, saml_request: nil)
            
            @issuer = saml_request&.issuer || issuer
            @principal = principal
            @audience = saml_request&.provider_name
            @assertion_consumer_service_url = saml_request&.assertion_consumer_service_url || assertion_consumer_service_url
            # @nameid_getter = saml_request&.nameid_getter
            
        end
        
        def build
        # Build the SAML assertion XML document
        # if !nameid_getter
        #     raise "NameID getter not defined for the Assertion"
        # end
        # nameid = nameid_getter.call(@principal)

        # We will need to validate all of these inputs
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

        xml.Assertion(ID: "_#{SecureRandom.uuid}", 
                      IssueInstant: "2023-04-01T00:00:00Z", 
                      Version: "2.0", 
                      xmlns: "urn:oasis:names:tc:SAML:2.0:assertion") do |assertion|

            assertion.Issuer @issuer
            assertion.Subject do |subject|
                # So far we only support the email address format
                subject.NameID "email@email.com", Format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
                subject.SubjectConfirmation(Method: "urn:oasis:names:tc:SAML:2.0:cm:bearer") do |confirmation|
                confirmation.SubjectConfirmationData NotOnOrAfter: "2023-04-01T01:00:00Z", Recipient: @assertion_consumer_service_url
                end
            end
            assertion.Conditions NotBefore: "2023-04-01T00:00:00Z", NotOnOrAfter: "2023-04-01T01:00:00Z" do |conditions|
                conditions.AudienceRestriction do |restriction|
                restriction.Audience @audience
                end
            end
            assertion.AuthnStatement AuthnInstant: "2023-04-01T00:00:00Z" do |statement|
                statement.AuthnContext do |context|
                context.AuthnContextClassRef "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
                end
            end
            assertion.AttributeStatement do |attribute_statement|
                attribute_statement.Attribute(Name: "emailAddress", NameFormat: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic") do |attribute|
                attribute.AttributeValue "user@example.com"
                end
            end
            assertion.AuthzDecisionStatement(Decision: "Permit", Resource: "https://resource.example.com") do |decision_statement|
                decision_statement.Action "Read", Namespace: "urn:oasis:names:tc:SAML:1.0:action:rwedc"
            end
        end

        xml.target!
        end
    end
end
