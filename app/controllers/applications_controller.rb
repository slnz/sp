class ApplicationsController < ApplicationController
  before_filter :redirect_to_closed, :except => :closed
  
  def index
    
  end
  
  def closed
    render :layout => false
  end
  
  def apply
    # If the current user has already started an application, pick it up from there
    @application = current_person.sp_applications.last
    if @application && @application.year == @application.project.try(:year)
      @project = @application.project
    else
      # If not, then we need a project param
      unless params[:p] && @project = SpProject.find(params[:p])
        redirect_to projects_path
        return false
      end
      @application = current_person.sp_applications.where(:project_id => @project.id, :year => @project.year).first
      @application ||= current_person.sp_applications.create!(:project_id => @project.id, :year => @project.year)
    end
    
    # I they alreay started an appliation for another project, and are now trying to do this one, we need to ask them what to do 
    if params[:p] && params[:p].to_i != @project.id
      redirect_to multiple_projects_application_path(@applicaiton)
      return false
    end
      
    # Make sure we have the right questions sheets from this project
    unless @application.question_sheets.order('id') == [@project.basic_info_question_sheet_id, @project.template_question_sheet_id].sort
      @application.answer_sheet_question_sheets.map(&:destroy)
      @application.answer_sheet_question_sheets.create(:answer_sheet_id => @application.id, :question_sheet_id => @project.basic_info_question_sheet_id)
      @application.answer_sheet_question_sheets.create(:answer_sheet_id => @application.id, :question_sheet_id => @project.template_question_sheet_id)
    end
    
    # QE Code
    @answer_sheet = @application 
    @presenter = AnswerPagesPresenter.new(self, @application)
    @elements = @presenter.questions_for_page(:first).elements
    @page = Page.find_by_number(1)
    render 'answer_sheets/edit'
  end
  
  protected
    def redirect_to_closed
      unless logged_in? && current_user.developer?
        redirect_to :action => :closed 
        return false
      end
    end
end
