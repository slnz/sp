class CampusesController < ApplicationController
  before_filter :ssm_login_required
  
  layout nil
 
  def search
    @answer_sheet = @application = SpApplication.find(params[:id])
    @answer_sheet.person.update_attribute(:universityState, params[:state])
    @school_picker = Fe::SchoolPicker.find(params[:dom_id].split('_').last)
  end
end
