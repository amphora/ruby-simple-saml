require 'xmldsig'
require 'nokogiri'

UNSIGNED = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Assertion
  xmlns="urn:oasis:names:tc:SAML:2.0:assertion" ID="ID" IssueInstant="2023-04-01T00:00:00Z" Version="2.0">
  <Issuer>https://idp.example.com</Issuer>
  <ds:Signature
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
    <ds:SignedInfo>
      <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod>
      <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"></ds:SignatureMethod>
      <ds:Reference URI="#ID">
        <ds:Transforms>
          <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>
        </ds:Transforms>
        <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"></ds:DigestMethod>
        <ds:DigestValue></ds:DigestValue>
      </ds:Reference>
    </ds:SignedInfo>
    <ds:SignatureValue></ds:SignatureValue>
  </ds:Signature>
  <Subject>
    <NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">email@email.com</NameID>
    <SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
      <SubjectConfirmationData NotOnOrAfter="2023-04-01T01:00:00Z" Recipient="https://sp.example.com"></SubjectConfirmationData>
    </SubjectConfirmation>
  </Subject>
  <Conditions NotBefore="2023-04-01T00:00:00Z" NotOnOrAfter="2023-04-01T01:00:00Z">
    <AudienceRestriction>
      <Audience>https://sp.example.com</Audience>
    </AudienceRestriction>
  </Conditions>
  <AuthnStatement AuthnInstant="2023-04-01T00:00:00Z">
    <AuthnContext>
      <AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</AuthnContextClassRef>
    </AuthnContext>
  </AuthnStatement>
  <AttributeStatement>
    <Attribute Name="emailAddress" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
      <AttributeValue>user@example.com</AttributeValue>
    </Attribute>
  </AttributeStatement>
  <AuthzDecisionStatement Decision="Permit" Resource="https://resource.example.com">
    <Action Namespace="urn:oasis:names:tc:SAML:1.0:action:rwedc">Read</Action>
  </AuthzDecisionStatement>
</Assertion>
XML

module SimpleSaml
    module XMLSecurity
       
        def sign_assertion(assertion)
            doc = Nokogiri::XML(assertion.build)
            namespaces = { 'saml' => 'urn:oasis:names:tc:SAML:2.0:assertion','ds' => 'http://www.w3.org/2000/09/xmldsig#' }
            assertion = doc.at_xpath('//saml:Assertion', namespaces)
            assertion_id = assertion['ID'] if assertion

            private_key = OpenSSL::PKey::RSA.new(SimpleSaml.config.private_key)
            certificate = OpenSSL::X509::Certificate.new(SimpleSaml.config.x509_certificate)
            
            # document = Nokogiri::XML(assertion.build)
            builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
                # Use ds:Signature as the root element and declare the 'ds' namespace
                xml['ds'].Signature('xmlns:ds' => "http://www.w3.org/2000/09/xmldsig#") do
                  xml['ds'].SignedInfo do
                    xml['ds'].CanonicalizationMethod(Algorithm: "http://www.w3.org/2001/10/xml-exc-c14n#")
                    xml['ds'].SignatureMethod(Algorithm: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")
                    xml['ds'].Reference(URI: "##{assertion_id}") do
                      xml['ds'].Transforms do
                        xml['ds'].Transform(Algorithm: "http://www.w3.org/2000/09/xmldsig#enveloped-signature")
                      end
                      xml['ds'].DigestMethod(Algorithm: "http://www.w3.org/2001/04/xmlenc#sha256")
                      xml['ds'].DigestValue nil
                    end
                  end
                  xml['ds'].SignatureValue nil
                  # If you have KeyInfo or other elements, they would go here
                end
              end
              signature_xml_string = builder.to_xml(
                save_with: Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS |
                           Nokogiri::XML::Node::SaveOptions::FORMAT |
                           Nokogiri::XML::Node::SaveOptions::NO_DECLARATION # Exclude the XML declaration
              )
            puts ""
            puts signature_xml_string
            puts ""
            # Parse the signature XML string to create a fragment
            signature_fragment = Nokogiri::XML::DocumentFragment.parse(signature_xml_string)


            # Find the <Issuer> element
            issuer_element = doc.at_xpath('//saml:Issuer', namespaces)

            issuer_element.add_next_sibling(signature_fragment)
            formatted_xml = doc.to_xml(
                save_with: Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS |
                           Nokogiri::XML::Node::SaveOptions::FORMAT
              )

            puts formatted_xml
            unsigned_document = Xmldsig::SignedDocument.new(UNSIGNED)
            signed_xml = unsigned_document.sign(private_key)
            puts "\n"
            puts signed_xml
        end

        def validate_request(saml_request)
            
        end
    end
end