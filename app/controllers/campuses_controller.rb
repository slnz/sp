class CampusesController < ApplicationController
  before_filter :ssm_login_required
  
  layout nil
 
  def search
    current_person.update_attribute(:universityState, params[:state])
    @answer_sheet = @application = SpApplication.find(params[:id])
    @school_picker = Fe::SchoolPicker.find(params[:dom_id].split('_').last)
  end
end
