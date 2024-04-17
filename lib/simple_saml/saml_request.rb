require 'base64'
require 'zlib'
require 'cgi'
require 'nokogiri'

FROM_URL = "lVhZj5vYEv4rLeWhH6wedtu0kkiH1djsGDC8jNhXA2aHX3%2Fp7kkmGc2dyUiWTR2q6nxUfVWn8OfOu5fNKxj6tNKjxxB1%2FRPouqjts7qi66ob7lFrRO2YBZGpi1%2Be075vXiGorAOvTOuuf8VgGIaGzaKD3nxB3ubq%2BYnZHGWV9%2Bblb22OMNR19Z9Lv%2FebwfOTwHx5%2Fv3gozEcYP5LDKPICx5hxAuJBshLhByiAx6FcYzCm2rXDZFQdb1X9V%2BeURjFX2D8BUGvMPkKY68w7D4%2FWRuqdwTob5vFfC%2Br7vUN5Jfnoa1ea6%2FLutfKu0fdax%2B8GkASXzfFV%2B%2Fb8%2F9o0vyzTdPWfR3U5fPXz2%2Far%2B%2Fo2q%2F%2FGq0uS6rfs%2Boz9KPV57B7NbYbXj%2B00R8Ywu57HKdp%2Bm3CfqvbBELf3MEktOmEm6tPz99to1Co4vpdpL2qrrINQba%2BJ0SK%2BrQOn0CZ1G3Wp%2Ff%2F4xiBEPjN8Us0By8BglefnqGfof2yIxj%2FhvDlXrfRp7bzXrrUQ4n9Hy71KI7aqAqiJ1MXvjx%2F%2BjUOvJteW6%2Fq4rq9dz%2BL%2Fwrrp8BF1RiVdROFL923p%2FsD2q87%2FJuAff0cBa9CFZRDl42R%2FEabxgui7kltozibxazbuPspjGJvKPund569fz%2BF3dP89sme7uE3GkbBf8oU9CP4v4gfsWKyZKu6%2F5jFLUuffsrdhxfLK4foq2NzUagUpwtcYs355OMnNclJERN4mVbk5p4skzRq0h1ZzC%2FviH40fl%2F4zoQP8S9U%2Fk69D4vm9CjxdiD1OA5Sr6OLvomLS%2B%2FeW6ihKXNvOgKKDYvKHzR4KPjSVuMK7dgoClxGau%2BMt9%2FdakoxdAPr%2BRZRbiLZVUeeJ10LrnfKKSGWebL2odnn%2BQj3Hq1QI44dRPic70%2BKXzxoNLXJ4rQSlUnrgmrdd7JARjbaoOvBI0a%2Bz%2BDeQqshZgx2EI3cnLpY4CVDdVhp4pVIsuMpGG3Olvg0i41FkkfV4dr27J9qI0ZsNTqw%2Bom0jVSpDOZo5jJKzGfsJounW1NfrwKzQtmBsM1HmXn5cBPU87g0vDUiaTJap0kk9uouS68Azadoyd3inAcLxKCArUNnpC38iOgDmbF185j7YZqXYR%2FuOVMd0sOxkIC%2BLAgX8N3jQPK4MuJehg%2FljlYRQ6S7NkVYuyJmaNzdwOSBNsIPGAE9JMxl4IMRmxppTgoYuJB2xkzpbgcksxb29mjGITznEAav5%2BUSE1BXc0SBjjUJ2cUaWe7sl8N1BExR7CuEIe9dIZAi5%2FY2BkcjlUpz4OKoRDc3uBkuu4QUnOpIEGVT1jtj3uUDLpJtA25UkMHm0TonO2tSLmYrbBU3MIRxpWXHy1dsh9RBV9z0AvMtZG1Bl1P0bj1wS51cE5h34%2F2s7MlQrYom50OJ3fusxGq537DZkTCGocEFgV%2BoHXTODZVhma6o8eJgCvc7xehGuDa2yKWqqMAGOQfal%2B90%2FoG%2Fb5S%2BRMt3et8ImGS83vsu0G8HUbz17j76Km3bnVaapkCUgEmgQCKYtHaspzCtPUu%2F1AU5EW0tngWnRvFpYjTnfKldIR0DGWisSGlgSlx8pldwphLZooBzBaUlSrowscBhLE0TGFDefLRv%2FHtYOzY8MyuQP3QDiSrm0b%2Fro5%2BzlUSbPEBMlk6myLlbcMhbi4OSQ3i3lgDlYM8mh2Ah7j5mDS7%2FIUvaNNHJ%2Bz4MA%2BTMQZ1ZWsFMJcUjLTKenGCK1lj7zKelz8%2Bjxp%2FL8KSXwV0e%2Fcotg0pOQ77crqXBvZPIhuVDzkHETfAiM2CVcnaWGBORrrr3vnb9eU0S%2BEjSuonW3nHw7HS2jJU1JAp8PA%2FYFlCy9Wyi8niul7TjWxzfdE8McCUfJQofxefzCsqPuNTS6f6rOFlJAvX7PmBLj3OX79JVmqSf8lRQXKbXrj13Pkxl7k2H3ds53%2FZFt9%2FVuenNdr2Kd3cMbaL4kPEpSYRMAjBPGw%2FeEHyM0VgKaCYAuEAzE3i7fwG1QAONLukUQAUOaMTIlrBVnZUQStm8jUqdde6FSpK9jPtIbFHUbEcjAsQVqsHg2idjrR2cVO31uJ7OuN90%2BSWyArfdPVgeGXRv11FtUOlaurMXIXf3NnFXqDVf13MIGx0%2BKVCpH7s97jOmdq068TKEq1MMxdlwb16TC6ah8sJkwYcIrx%2F7my4qco%2B7U1Dnw9XdF%2FStLYgsFpgIjLOac1YS7XbMip5svtdJziq5R0cohG1dnX7%2FADs2PQjjtdBy6cGru7VUWfTIAHPPOmDJjr6zNTjB7k%2FnpYmuuCPSIaURCssDZptNcxSKw8EYS%2BkB5SunMNfoHF4e9sXt95kVp1iyqoB%2FcLZ11DlYLwqKhV3GKi7hJY99qxUKapQOk1CKZUslrgy1q1o%2BljuFWJQK8oOjXw5IRI5Mvq%2FI%2By7MEo49xoKgehG1lk4IrzihR6Qkq5x5unGn1p7Nqbgx6L4PsDk%2BIeRyMpJqmuTm5hp0OF9c3Z0cb69l5xTVaRtOxnq0Ag52AuR20JHcHxVg3sT9qOQRMaFKtjsi7ZHJ7alld1fBH3oOiyJXZ7aTQtcTFqOVUd%2BFcLR3SM%2FRM7ywZhAt1AGCw7O%2FKuWRoqGL04t76eHFnkwjUXnrcijaw8IQknpnli0%2FwvolnIpgDZWqotvMoo%2B7i53FE4RShXzFEhORFZAE1FEUW7IU44yalfV6DMsmtfG3dqQBqkakybyC8K3eThrOcolmNvlutygkP5%2BIm2W69CSiNxvRcLDVwmna6lWHc4pKJq4G%2F6jLfOhegXaCKGBulcJS0HvP%2B7MnAa3jAFBokLCAWQLzmmbM1kiokBh1ZvfQHYYzD4BrduMRx%2BnhCmN%2BwtjEBZy8oK8u3TBSpXY2sNC9WrjAqGlj327WwwvgG93HD0I9x80BUQzPlrGeia2Sbms23XjgLaDbVyrizwkU1IkK7%2BMIXivqTtcXuqu4KiPu03TuGds3lt5W1kph5MojhlVmMIa8ntH9DrFITI%2FQ3MEHAeySHFdzBzbvppzbl14%2BjZqhX4qmmg0oVD3aeWgjOzJ7TeUYeIQqExcDK%2B6O0SjmW6O7YCs1O8YqdlvfC8PZm126adFqQ5n35DLdNE6P66ZIV6nvfXtvVy11GtDLctaHe3ynnJ7kEmgaVgY9FUG5kquW5NoeZBhdU%2FzRSZetQB8gj6%2BSIvHRmcgx365xamnRhngcNd7ODMhjsTsqE7Gec7Hv4fu5wC8jeruOTM0YVHNzrtdUrroGQrmjTyVkiAr2WIiLv2MO6IwdW3z2E74oAZwmdr7E3didml5Ib%2FFaWse0WtKEu6b6ZU67Nk%2F1dRAOe9KCj3Hw2F7ktrPssZGdckTMVnlVxven5THNiqvFxgPH3NiSZxm7iIGDd0HuHxAyhfCTV1jZxIpB9QBJ2i3GkGmXA3MoyvWc2fWyyEcBNBM7NpMIVpQ8TNqtcK%2FjMsZiNjPR2jPOScIUT2oJI4kOj7a7bHNCqWlIoJ5wQog6WyHiySm6R6fOYSOXLf4xcPx1iPi%2B%2BDFmQD8OID8NKF8%2FXkl%2F%2Fmvg6%2F8A"

module SimpleSaml
    class SamlRequest 
        include SimpleSaml::XMLSecurity

        attr_reader :id, :version, :provider_name, :issue_instant, :destination, :protocol_binding, :assertion_consumer_service_url, :issuer, :name_id_format, :name_id_allow_create, :doc

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
            @name_id_format = name_id_policy&.[]('Format') || nil
            @name_id_allow_create = name_id_policy&.[]('Format') || false
        
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

        def to_s(format: false)
            @doc.to_s
        end

        def valid?
            # Check if the request is legitimately signed
            validate_request(req)
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
                base_64_decoded_request
            end
        end
    end
end