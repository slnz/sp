require 'spec_helper'

describe SchoolPicker do
  before(:each) do
    @person = create(:person)
    @project = create(:sp_project)
    @application = create(:sp_application, person: @person, project: @project)
    @school_picker = SchoolPicker.new
  end
  
  describe "when calling the 'state' function" do
    it "should return a blank string if no application specified" do
      response = @school_picker.send(:state)
      response.should == ""
    end
    it "should return the universityState if the person of application has a universityState record" do
      @person.universityState = 'University State'
      @person.save
      response = @school_picker.send(:state, @application)
      response.should == @person.universityState
    end
    it "should return the campus state if the person of application do not have a universtyState record" do
      campus = create(:campus, name: 'Campus Name', state: 'Campus State')
      @school_picker.should_receive(:response).with(@application).and_return(campus.name)
      response = @school_picker.send(:state, @application)
      response.should == campus.state
    end
  end
  
  describe "when calling 'colleges' function" do
    it "should return a blank array if no application specified" do
      response = @school_picker.send(:colleges)
      response.should == []
    end
    it "should return a blank array if the given application do not have a state record" do
      @school_picker.should_receive(:state).with(@application).and_return("")
      response = @school_picker.send(:colleges, @application)
      response.should == []
    end
    it "should return an array of campus names if the given application has a state record" do
      campus = create(:campus, name: 'Campus Name', state: 'Campus State', type: 'College', isClosed: nil)
      @school_picker.should_receive(:state).exactly(2).times.with(@application).and_return(campus.state)
      response = @school_picker.send(:colleges, @application)
      response.first.should == campus.name
    end
  end
  
  describe "when calling 'high_schools' function" do
    it "should return a blank array if no application specified" do
      response = @school_picker.send(:high_schools)
      response.should == []
    end
    it "should return a blank array if the given application do not have a state record" do
      @school_picker.should_receive(:state).with(@application).and_return("")
      response = @school_picker.send(:high_schools, @application)
      response.should == []
    end
    it "should return an array of campus names if the given application has a state record" do
      campus = create(:campus, name: 'Campus Name', state: 'Campus State', type: 'HighSchool')
      @school_picker.should_receive(:state).with(@application).and_return(campus.state)
      response = @school_picker.send(:high_schools, @application)
      response.first.should == campus.name
    end
  end
  
  describe "when calling 'validation_class' function" do
    it "should return a blank string if SchoolPicker is not required" do
      @school_picker.should_receive(:required?).and_return(false)
      response = @school_picker.send(:validation_class)
      response.should == ""
    end
    it "should return a string if SchoolPicker is required" do
      @school_picker.should_receive(:required?).and_return(true)
      response = @school_picker.send(:validation_class)
      response.should == "validate-selection required"
    end
  end
end