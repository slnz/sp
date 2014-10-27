require 'spec_helper'

describe Authentication do
  context '#provider_name' do
    it 'should return OpenID for open_id provider' do
      p = Authentication.new provider: 'open_id'
      expect(p.provider_name).to eq('OpenID')
    end

    it 'should return provider titleized' do
      p = Authentication.new provider: 'test titleize'
      expect(p.provider_name).to eq('test titleize'.titleize)
    end
  end
end
