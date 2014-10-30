require 'spec_helper'

describe Region do
  context '#standard_regions' do
    it 'should work' do
      allow(Infobase::Region).to receive(:get).and_return([{"id" => "1", "abbrv" => "GL"}, {"id" => "2", "abbrv" => "AA"}])
      expect(Region.standard_regions.first.id).to eq("1")
    end
  end

  context '#campus_regions' do
    it 'should work' do
      allow(Infobase::Region).to receive(:get).and_return([{"id" => "1", "abbrv" => "NC"}, {"id" => "2", "abbrv" => "AA"}])
      expect(Region.campus_regions.first.id).to eq("1")
    end
  end

  context '#standard_regions_hash' do
    it 'should work' do
      allow(Infobase::Region).to receive(:get).and_return([{"name" => "Great Lakes", "id" => "1", "abbrv" => "GL"}, {"name" => "A non-standard region", "id" => "2", "abbrv" => "AA"}])
      standard_regions_hash = Region.standard_regions_hash
      expect(standard_regions_hash).to have_key("Great Lakes")
      expect(standard_regions_hash).to_not have_key("A non-standard region")
    end
  end
end
