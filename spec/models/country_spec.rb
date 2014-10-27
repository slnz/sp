require 'spec_helper'

describe Country do
  context '#to_hash_US_first=' do
    it 'should return a hash of all countries with the US first' do
      create(:country, country: 'Canada', code: 'CA')
      create(:country, country: 'United States', code: 'US')
      countries = Country.to_hash_US_first
      expect(countries.to_a).to eq([['United States', 'US'], ['Canada', 'CA']])
    end
  end

  context '#full_name' do
    it 'should run' do
      create(:country, country: 'United States', code: 'US')
      expect(Country.full_name('US')).to eq('United States')
    end
  end
end
