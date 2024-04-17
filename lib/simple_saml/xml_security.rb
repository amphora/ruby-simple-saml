require 'xmldsig'
require 'nokogiri'

UNSIGNED = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="pfx41d8ef22-e612-8c50-9960-1b16f15741b3" Version="2.0" ProviderName="SP test" IssueInstant="2014-07-16T23:52:45Z" Destination="http://idp.example.com/SSOService.php" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" AssertionConsumerServiceURL="http://sp.example.com/demo1/index.php?acs">
  <saml:Issuer>http://sp.example.com/demo1/metadata.php</saml:Issuer>
  <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
    <ds:SignedInfo>
      <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
      <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
      <ds:Reference URI="#pfx41d8ef22-e612-8c50-9960-1b16f15741b3">
        <ds:Transforms>
          <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
          <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
        </ds:Transforms>
        <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
        <ds:DigestValue></ds:DigestValue>
      </ds:Reference>
    </ds:SignedInfo>
    <ds:SignatureValue></ds:SignatureValue>
    <ds:KeyInfo>
      <ds:X509Data>
        <ds:X509Certificate>cr</ds:X509Certificate>
      </ds:X509Data>
    </ds:KeyInfo>
  </ds:Signature>
  <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" AllowCreate="true"/>
  <samlp:RequestedAuthnContext Comparison="exact">
    <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
  </samlp:RequestedAuthnContext>
</samlp:AuthnRequest>
XML

CERTIFICATE = <<-CERT
-----BEGIN CERTIFICATE-----
MIIGHzCCBAegAwIBAgIUCQ8owdhoaVRKok9w5roLJIYo24wwDQYJKoZIhvcNAQEL
BQAwgZ4xCzAJBgNVBAYTAlVLMRIwEAYDVQQIDAlXb2tpbmdoYW0xDzANBgNVBAcM
BkxvbmRvbjEnMCUGA1UECgweYmV0dGVyY29udmVyc2F0aW9ucy5mb3VuZGF0aW9u
MQwwCgYDVQQDDANiY2YxMzAxBgkqhkiG9w0BCQEWJGhlbGxvQGJldHRlcmNvbnZl
cnNhdGlvbnMuZm91bmRhdGlvbjAeFw0yNDAzMjExMDU1MTRaFw0yNTAzMjExMDU1
MTRaMIGeMQswCQYDVQQGEwJVSzESMBAGA1UECAwJV29raW5naGFtMQ8wDQYDVQQH
DAZMb25kb24xJzAlBgNVBAoMHmJldHRlcmNvbnZlcnNhdGlvbnMuZm91bmRhdGlv
bjEMMAoGA1UEAwwDYmNmMTMwMQYJKoZIhvcNAQkBFiRoZWxsb0BiZXR0ZXJjb252
ZXJzYXRpb25zLmZvdW5kYXRpb24wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
AoICAQClChA/k4AC1SiydrPYz5IlNUXvOoisZKBgg6N4b1fVBBxWev1ALz/oAuZW
HSzoY49PWz8zHJ4bpsjKeVcZr+qEG1uRa+sBrcnRQh+WyIjZ6W5mOBzjzzJd0Ss4
wO/lR8s64bDUQTnsLKudzYkukJSZXapjIUSPGIwV07e4oq6XRLONt4ZwcojuTZ6k
CXrk5ifIDeAvxPjFVge++Dz2HWGtR9FVlFqs5O5WVTYt6qA+Eh7IvTkQjMqGP+zl
PE28DAU6EYAyi8bY8kMIWtHJypeT4YLCdBQ5OEGAD80/j2/fduSvlMq/jzFODTeJ
dKqWKZt6iVfh3gzPAGqFWV8RF0RkkBE0ZDVkKdKjfbVrIkBvM7wIlLlrBgZN/rzP
lqymB1VBPAj7YRK71e9vDj6n9m+digFE8fIIPaeBzlYd0z45Re9MNPFUHXFHrWxU
wkXD26tc3xfH19yHSgnwwNpXZSCdxKZRZwYa6QiJh2RCW0gvovVcF0Yc1X7R1jbv
OAUXL6vOje5w2Oi+81r8DjWwrE+TIbutF3eeZRD2jwRRgE3COvR+d0e6Y9aYRi4k
VxAeyB7/0dJbzOl8BC/KYtL6MqafaNC1elXsj/e60Iud9RsUlrGv0RKdwkczdOnn
CriVC8+KWifw/2BkNT3gU1NOAgcB8LLr9lLfiBxOzT8dlphW4QIDAQABo1MwUTAd
BgNVHQ4EFgQUpj++yO9GxH5XVUZCwL2XW1Q4A24wHwYDVR0jBBgwFoAUpj++yO9G
xH5XVUZCwL2XW1Q4A24wDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOC
AgEADycUThiDaMIBd5vRD+qRYDFU7AFp+v844CuT03bgDW5KAHactnKsuvBlQJS3
dZTV4IDPhpWXXVqac0XCtfq5PJfp71OSaWN3tDfVlCroEheBzayAs6nP1bxg/cog
P06fe0znBmCoKCsnFni5mwwJtDWbSytWOznODNna5uzND3D9TJ26+1V93Re2jY4u
IA+gj4PjY0UmUNjWKtNHvQSRKkpnxS/dPaCYqQvEvD6QPFD0v/nU4LcVfs8evLjo
MHK3zBxYSzLsBAoddxaxZCpr2ns6njt9ywXQFRfopkhzMttbW6WnrBHu2KyJRumf
mBYt9Fg/wuzD2Hkclz9zQgjQ6Ai3CoBG8Yhy8DAqAjfTMOMGeJ5j3bWo4Byr2p5q
8QGWiS/aE3m2N5fRjFfba46xk4Kv2XTvDoDSBpXYTThNnsp/2F8bBg9d2IWvkLyb
+D72x38r4xbgGklA0hgWjyfsvsHptIhXfzlV8hnyhgFThRKxhsrjhRzuI769V08f
cq//lGF0qaNCBYL3WPGPN46HyqwxOZQfSq43ZfVNxN3KLcY4scjb719h/4HakViw
ELcnqAghsySuiQK7D7klzJiWoyyN8IApwEvpwLAz297wQXkZTvyvfLixDeztDYHM
3OaMr5Sge7qrsK9DalQQ1cPH45IesWO5fwYksqsPxdpNlr4=
-----END CERTIFICATE-----
CERT

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

            # Obtain the SP metadata, which includes the signing certificate
            sp_entity_id = sp_entity_id_from_request(saml_request)
            sp_metadata = SimpleSaml.config.get_sp_metadata(sp_entity_id)
            sp_certificate_str = sp_metadata[:signing_certificate]
            sp_certificate = OpenSSL::X509::Certificate.new(Base64.decode64(sp_certificate_str))

            # Extract the certificate from the SAML assertion
            assertion_certificate_str = saml_request.doc.at_xpath("//*[local-name()='X509Certificate']/text()").to_s
            assertion_certificate = OpenSSL::X509::Certificate.new(Base64.decode64(assertion_certificate_str))

            # Compare fingerprints
            sp_fingerprint = Digest::SHA256.hexdigest(sp_certificate.to_der)
            assertion_fingerprint = Digest::SHA256.hexdigest(assertion_certificate.to_der)

            unless sp_fingerprint == assertion_fingerprint
              raise "Certificate fingerprint mismatch"
            end

            # Validate the signature
            signed_document = Xmldsig::SignedDocument.new(saml_request.doc)
            unless signed_document.validate(assertion_certificate)
              raise "Signature validation failed"
            end

            true
        end

        private 

        def sp_entity_id_from_request(saml_request)
            issuer_element = saml_request.doc.at_xpath("//*[local-name()='Issuer']/text()")
            sp_entity_id = issuer_element.to_s.strip unless issuer_element.nil?
            sp_entity_id
          end
    end
end