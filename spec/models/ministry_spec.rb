require 'spec_helper'

describe Ministry do
  context '#to_s=' do
    it 'should return the name' do
      m = Ministry.new name: 'ministry_name'
      expect(m.to_s).to eq('ministry_name')
    end
  end
end
