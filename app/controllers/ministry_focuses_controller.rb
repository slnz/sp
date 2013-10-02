class MinistryFocusesController < ApplicationController
  def index
    @focuses = SpMinistryFocus.all
    render :xml => @focuses.to_xml.gsub!("sp-ministry-focus", "sp_ministry_focus")
  end
end
