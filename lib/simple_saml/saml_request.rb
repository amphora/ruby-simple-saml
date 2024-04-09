require 'base64'
require 'zlib'
require 'cgi'
require 'nokogiri'

FROM_URL = "nVbZkqJIFH2fiPkHw37ssFgEFaKtiWRTVJBNLX1jSRBlk0QT%2FfpBraq2arorZubBMOIu5557yZt5fiA3TQoeHKttZsHDEaKqVadJhvibY9g%2BlhmfuyhGfOamEPGVz9tAm%2FH0E8kXZV7lfp60H1K%2BznARgmUV51m7pUrDdhHWDBUMYEjTHdij6M7AZ8kOx%2FXIDuVRvZBi%2BwzlddutJSxRkzVsNyDtllHmpziApd7gD9u20aoa2g0iQkeoZqhys6qJJCmmQ%2FY7VM%2BhuzxL8wy7abekJjLO3OoGtq2qgieIOCieYO2mRQKf%2FDwlbHtuw%2FIU%2B%2FCp2Ba3crc2hTgL4iz6ukPvHoT4seMYHWNuO%2B0WeOtazDN0TGH5Cr%2BwZu8k0EcOAUxzimiwYH0l8Zfro%2Fbzn3%2B0Wj%2BuQ%2BZvrZbPX%2BWmsHIDt3Kv6T%2BIx6wbTIB4O46aSRxL%2BPr5AvTOBmP8hLtPeRkRNEmSBMkRTUyA4ujbncZPBBioWZi%2FGu9m0c3yLPbdJL7cJq3BapsHLZBEeRlX2%2FQ3ZSiCIq9lOrD2Oz7FZN%2FaxAfcd8L%2FEvAD7xK5HbR1qU%2BYFgxhCTMfthaWOmx%2F%2B7dH8h3kDuOUbobCvEzRg%2BOT67%2FxhdkJJnkBgw56a%2FuB%2Bn8H%2F3K6DRjxuy6uZaQ4ahbn%2F4z908gf4ZZucoTP54ne818W2KydVJORAZFg0Pr%2BsFbU4Y3UY%2FD7lyMeP93biSR%2BdSQ%2FHJw7SsRCjTsb2RSlqUxMt%2FTB7mfhdDDOld55XIJAN%2Bttn9xvB4WlMlNX99b6fMYhZaCw%2FXXwfTfvxXrkDrLMw1sPONPRi7qZTyb2MXoZAc06b9COKA9ZhJ3Jnp2mx513yI8WZc8U5OV99YgvkOt25QiGggdkZmKp%2FSXtStw6SoUuyn3jAGLaDLm%2BPHxv6oH%2Fz8am8PyP7XthSU5qFv%2FTzK9m8XoNhc1mVvBZU1XR3YkiCOYRwKoAouYnAV2I9oftPh5xmBSAaSpAEmzNRFg019LSNEcynlD%2BRXY0QR4BaiGLAE9NWkHuanPyU7ZYO%2FJSE7S7L8KaQ7OJN%2BIyd8VE9ordaZaPlTuWJAH24otsAkdK5Y%2FqZJbqJ88BUMFkrUugqzk%2B1iSV1XaBe7M5H22aotbiBUyESF8KYO2AbHnRLA3Ld3xVAoW0XtXFJuXOXppsNWuBZXzzTSVQG166RB4dFF4sTLxUq5ULWN6xNE3KdDxLl8x6RWFvtDiuaa7S1FGoAXIk2oeRrXpdyZSbGS0AYEY6kEQhNqdCZIr904LoWcRcAD1hijZjZkZ7qkn7B2HeJ1wtNHYLY2LYGcsFREi61sEW2cF6XRpHcy6dgwUQYnGfzTPuvCRDeZ0ynn4Kd2XuyMHAk5JDzubgBSyAOngZG0Ux0S%2F9ova2mxV57LIHhjUml5HGZeKJ86JEMteTmXemNotgjOxYUgvNG0UhsSnrg4ubEZlAyCmAnR0Irr2PTUZWInPRRbQuF%2Bu6j8c979CvJ8rUZXo7QQoZPL7O0CJ3ghBhJQdfxkrgFusIYIEBlgXi8oszBubXuRlIn9PK6Psl3bNp%2FCIjDFCXlCmmFCYFJHqMIhQaVRqXeQJhfdKiTVKSBEqVrsE6K68%2FHihndi%2FHwrnWdq6ZpgmRmXXvEC2Xl2DrOkAvVJk6Y%2FmynCTb4ISZbWod5en64LiKNoMXElmzPjdbQKk2Vriv7ThlX1hr5%2FsejGIlT8d5QWVyueyZw%2Ftifl6qD%2FfTp0W82R4X9uNq%2F3zdC%2F4qbFTJyJPYP7eU5j52q9%2BrDuqJulnioBPeQnmYunECgqCECDXqI0lyLJaw4TdsV%2BXx7Rl5rfWq%2BmBw04CNQqlgXbXEPC3cMkZXmdRoC796f%2FZvSuIxVkwaVdfcxc9fCj%2Bf969xjdlo%2FnBeBldZBf2m8O3VKfKyepUpvwS%2FD%2BwLyk3Em%2F9RzT7%2FDQ%3D%3D"

module SimpleSaml
    class SamlRequest 
        attr_reader :id, :version, :provider_name, :issue_instant, :destination, :protocol_binding, :assertion_consumer_service_url, :issuer, :name_id_format, :name_id_allow_create

        def initialize(request_from_params)
            @doc = Nokogiri::XML(decode_and_inflate(request_from_params))

            authn_request = @doc.at_xpath('//samlp:AuthnRequest', 'samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol')
            name_id_policy = @doc.at_xpath('//samlp:NameIDPolicy', 'samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol')
            
            # Extracting specific attributes and storing them in instance variables
            @id = authn_request['ID']
            @version = authn_request['Version']
            @provider_name = authn_request['ProviderName']
            @issue_instant = authn_request['IssueInstant']
            @destination = authn_request['Destination']
            @protocol_binding = authn_request['ProtocolBinding']
            @assertion_consumer_service_url = authn_request['AssertionConsumerServiceURL']
            @issuer = @doc.at_xpath('//saml:Issuer', 'saml' => 'urn:oasis:names:tc:SAML:2.0:assertion').text
            @name_id_format = name_id_policy['Format']
            @name_id_allow_create = name_id_policy['AllowCreate'] || false
        
            # puts "SAML Request Information:"
            # puts "-------------------------"
            # puts "ID: #{id}"
            # puts "Version: #{version}"
            # puts "ProviderName: #{provider_name}"
            # puts "IssueInstant: #{issue_instant}"
            # puts "Destination: #{destination}"
            # puts "ProtocolBinding: #{protocol_binding}"
            # puts "AssertionConsumerServiceURL: #{assertion_consumer_service_url}"
            # puts "Issuer: #{issuer}"
            # puts "NameIDPolicy Format: #{name_id_format}"
            # puts "NameIDPolicy AllowCreate: #{name_id_allow_create}"

        end

        private

        def decode_and_inflate(encoded_request)
        
            url_decoded_request = CGI.unescape(encoded_request)
            base_64_decoded_request = Base64.decode64(url_decoded_request)
            
            # Inflate the decoded request. Try to inflate, and if it fails, return the original decoded request
            begin
                Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(base_64_decoded_request)
            rescue Zlib::DataError
                # If inflation fails, it might not be deflated. Return the original decoded request.
                decoded_request
            end
        end
    end
end