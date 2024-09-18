# frozen_string_literal: true
require "spec_helper"

RSpec.describe SimpleSaml::XMLSecurity do
    include SimpleSaml::XMLSecurity
    before do
        SimpleSaml.configure do |config|
            config.service_providers = [{
                entity_id: "http://localhost:3000/users/saml/sign_in",
                metadata_url: "http://localhost:3000/users/saml/metadata"
            }]
        end
    end

    it "does something useful" do
        expect(true).to eq(true)
    end
    
    # These tests do not stand alone, request responses need to be stubbed
    it "correctly validates valid saml requests" do
        skip ""
        req = SimpleSaml::SamlRequest.new(FROM_URL)
        valid = validate_request(req)
        
        expect(valid).to eq(true)
    end
end

