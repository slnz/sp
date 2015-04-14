require 'spec_helper'

describe SpDesignationNumber do
  before(:each) do
  end

  it 'ensures that the designation_number is 7 digits' do
    d = SpDesignationNumber.new(designation_number: '123456', project: create(:sp_project))
    d.save
    expect(d.designation_number).to eq('0123456')
  end
end
