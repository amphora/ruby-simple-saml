require 'xmldsig'
require 'nokogiri'

module SimpleSaml
    module XMLSecurity
       
        def sign_assertion(assertion)
            doc =assertion.raw
            namespaces = { 'saml' => 'urn:oasis:names:tc:SAML:2.0:assertion','ds' => 'http://www.w3.org/2000/09/xmldsig#' }
            assertion_doc = doc.at_xpath('//saml:Assertion', namespaces)
            assertion_id = assertion_doc['ID'] if assertion

            private_key = OpenSSL::PKey::RSA.new(SimpleSaml.config.private_key)
            certificate = OpenSSL::X509::Certificate.new(SimpleSaml.config.x509_certificate)
            
            # document = Nokogiri::XML(assertion.build)
            sigbuilder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
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
                xml['ds'].KeyInfo do
                    xml['ds'].X509Data do
                        # Assuming SimpleSaml.config.x509_certificate returns the certificate as a string
                        # Strip the header, footer, and any newlines
                        cert_text = SimpleSaml.config.x509_certificate
                        cert_text = cert_text.gsub(/-----BEGIN CERTIFICATE-----/, '')
                        cert_text = cert_text.gsub(/-----END CERTIFICATE-----/, '')
                        cert_text = cert_text.gsub(/\n/, '')
                
                        xml['ds'].X509Certificate cert_text
                    end
                  end
                end
            end
              
            # Find the <Issuer> element
            issuer_element = doc.at_xpath('//saml:Issuer', namespaces)
            issuer_element.add_next_sibling(sigbuilder.doc.root)

            formatted_xml = doc.to_xml(
              save_with: Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS |
                         Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
            )

            unsigned_document = Xmldsig::SignedDocument.new(doc)
            signed_xml = unsigned_document.sign(private_key)
            signed_xml = signed_xml.lines[1..-1].join #get rid of the first line which is the xml declaration that xmldsig re-adds
            signed_xml
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