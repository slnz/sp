class CampusesController < ApplicationController
  before_filter :ssm_login_required
  
  layout nil
 
  def search
    # @campuses = Campus.find_all_by_state(params[:state], :order => :name)
    current_person.update_attribute(:universityState, params[:state])
    @application = SpApplication.find(params[:id])
    @school_picker = SchoolPicker.find(params[:dom_id].split('_').last)
  end
end
