require 'spec_helper'

describe SchoolPicker do
  let(:project) { create(:sp_project) }

  before(:all) do
    @person = create(:person)
    @application = create(:sp_application, person: @person, project: @project)
    @school_picker = SchoolPicker.new
  end
  
  describe "when calling the 'state' function" do
    it "returns a blank string if no application specified" do
      response = @school_picker.send(:state)
      expect(response).to eq("")
    end
    it "returns the universityState if the person of application has a universityState record" do
      @person.update_column(:universityState, 'FL')
      response = @school_picker.send(:state, @application)
      expect(response).to eq(@person.universityState)
    end
    it "returns the campus state if the person of application do not have a universtyState record" do
      @person.update_column(:universityState, nil)
      campus = create(:campus, name: 'Campus Name', state: 'CA')
      expect(@school_picker).to receive(:response).with(@application).and_return(campus.name)
      response = @school_picker.send(:state, @application)
      expect(response).to eq(campus.state)
    end
  end
  
  describe "when calling 'colleges' function" do
    it "returns a blank array if no application specified" do
      response = @school_picker.send(:colleges)
      expect(response).to eq([])
    end
    it "returns a blank array if the given application do not have a state record" do
      expect(@school_picker).to receive(:state).with(@application).and_return("")
      response = @school_picker.send(:colleges, @application)
      expect(response).to eq([])
    end
    it "returns an array of campus names if the given application has a state record" do
      campus = create(:campus, name: 'Campus Name', state: 'Campus State', type: 'College', isClosed: nil)
      expect(@school_picker).to receive(:state).exactly(2).times.with(@application).and_return(campus.state)
      response = @school_picker.send(:colleges, @application)
      expect(response.first).to eq(campus.name)
    end
  end
  
  describe "when calling 'high_schools' function" do
    it "returns a blank array if no application specified" do
      response = @school_picker.send(:high_schools)
      expect(response).to eq([])
    end
    it "returns a blank array if the given application do not have a state record" do
      expect(@school_picker).to receive(:state).with(@application).and_return("")
      response = @school_picker.send(:high_schools, @application)
      expect(response).to eq([])
    end
    it "returns an array of campus names if the given application has a state record" do
      campus = create(:campus, name: 'Campus Name', state: 'Campus State', type: 'HighSchool')
      expect(@school_picker).to receive(:state).with(@application).and_return(campus.state)
      response = @school_picker.send(:high_schools, @application)
      expect(response.first).to eq(campus.name)
    end
  end
  
  describe "when calling 'validation_class' function" do
    it "returns a blank string if SchoolPicker is not required" do
      expect(@school_picker).to receive(:required?).and_return(false)
      response = @school_picker.send(:validation_class)
      expect(response).to eq("")
    end
    it "returns a string if SchoolPicker is required" do
      expect(@school_picker).to receive(:required?).and_return(true)
      response = @school_picker.send(:validation_class)
      expect(response).to eq("validate-selection required")
    end
  end
end