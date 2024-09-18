require "spec_helper"

RSpec.describe SimpleSaml::Configurator do
    include SimpleSaml::XMLSecurity

    before do
        SimpleSaml.configure do |config|
            config.service_providers = [{
                entity_id: "http://localhost:3000/users/saml/metadata",
                metadata_url: "http://localhost:3000/users/saml/metadata"
            }]
        end
    end

    # These tests do not stand alone, request responses need to be stubbed
    it "fetches metadata" do
        skip ""
        SimpleSaml.config.get_sp_metadata("http://localhost:3000/users/saml/metadata")
    end
end