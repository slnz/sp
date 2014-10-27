require 'spec_helper'

describe SpWorldRegion do
  context "SpWorldRegion#skip_fields_for_gr" do
    it "should return an array" do
      s = SpWorldRegion.new
      expect(SpWorldRegion.skip_fields_for_gr.class).to be Array
    end
  end
  context "SpWorldRegion#global_registry_entity_type_name" do
    it "should return a string" do
      expect(SpWorldRegion.global_registry_entity_type_name.class).to be String
    end
  end
end
