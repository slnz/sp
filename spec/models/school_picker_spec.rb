require 'spec_helper'

describe Fe::SchoolPicker do
  let(:project) { create(:sp_project) }

  before(:all) do
    @person = create(:person)
    @application = create(:sp_application, person: @person, project: @project)
    @school_picker = Fe::SchoolPicker.new
  end

  describe "when calling the 'state' function" do
    it 'returns a blank string if no application specified' do
      response = @school_picker.send(:state)
      expect(response).to eq('')
    end
    it 'returns the universityState if the person of application has a universityState record' do
      @person.update_column(:universityState, 'FL')
      response = @school_picker.send(:state, @application)
      expect(response).to eq(@person.universityState)
    end
    it 'returns the campus state if the person of application do not have a universtyState record' do
      @person.update_column(:universityState, nil)
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=Campus%20Name')
        .to_return(status: 200, body: '{"target_areas":[{"name":"Campus Name", "state": "CA"}]}', headers: {})
      campus_name = 'Campus Name'
      expect(@school_picker).to receive(:response).with(@application).and_return(campus_name)
      response = @school_picker.state(@application)
      expect(response).to eq('CA')
    end
  end

  describe "when calling 'colleges' function" do
    it 'returns a blank array if no application specified' do
      response = @school_picker.send(:colleges)
      expect(response).to eq([])
    end
    it 'returns a blank array if the given application do not have a state record' do
      expect(@school_picker).to receive(:state).with(@application).and_return('')
      response = @school_picker.send(:colleges, @application)
      expect(response).to eq([])
    end
    it 'returns an array of campus names if the given application has a state record' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bstate%5D=Campus%20State&filters%5Btype%5D=College')
        .to_return(status: 200, body: '{"target_areas":[{"name":"Campus Name", "state": "Campus State"}]}', headers: {})
      expect(@school_picker).to receive(:state).exactly(2).times.with(@application).and_return('Campus State')
      response = @school_picker.send(:colleges, @application)
      expect(response.first).to eq('Campus Name')
    end
  end

  describe "when calling 'high_schools' function" do
    it 'returns a blank array if no application specified' do
      response = @school_picker.send(:high_schools)
      expect(response).to eq([])
    end
    it 'returns a blank array if the given application do not have a state record' do
      expect(@school_picker).to receive(:state).with(@application).and_return('')
      response = @school_picker.send(:high_schools, @application)
      expect(response).to eq([])
    end
    it 'returns an array of high school names if the given application has a state record' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Btype%5D=HighSchool')
        .to_return(status: 200, body: '{"target_areas":[{"name":"High School Name", "state": "High School State"}]}', headers: {})
      expect(@school_picker).to receive(:state).with(@application).and_return('Campus State')
      response = @school_picker.send(:high_schools, @application)
      expect(response.first).to eq('High School Name')
    end
  end

  describe "when calling 'validation_class' function" do
    it 'returns a blank string if SchoolPicker is not required' do
      expect(@school_picker).to receive(:required?).and_return(false)
      response = @school_picker.send(:validation_class)
      expect(response).to eq('')
    end
    it 'returns a string if SchoolPicker is required' do
      expect(@school_picker).to receive(:required?).and_return(true)
      response = @school_picker.send(:validation_class)
      expect(response).to eq('validate-selection required')
    end
  end
end
