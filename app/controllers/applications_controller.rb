class ApplicationsController < AnswerSheetsController
  prepend_before_filter :ssm_login_required, :except => [:closed]
  before_filter :redirect_to_closed, :except => [:closed]
  
  def closed
    render :layout => false
  end
  
  def apply
    @project = SpProject.find(params[:p]) if params[:p]
    # If the current user has already started an application, pick it up from there
    @application = current_person.sp_applications.last 
    
    if @application && @application.year == @application.project.try(:year)
      if @project
        if params[:force] == 'true' 
          @application.update_attribute(:project_id, params[:p])
          # Do a redirect to reset variables
          redirect_to apply_path
          return false
        else
          # I they alreay started an appliation for another project, and are now trying to do this one, we need to ask them what to do 
          if @application.project.present? && @application.project != @project 
            redirect_to multiple_projects_application_path(@application, :p => params[:p])
            return false
          end
        end
      end

      @project ||= @application.project
      # If not, then we need a project param
    else
      if @project
        @application = current_person.sp_applications.where(:project_id => @project.id, :year => @project.year).first
        @application ||= current_person.sp_applications.create!(:project_id => @project.id, :year => @project.year)
      else
        redirect_to projects_path
        return false
      end
    end
    
    # if @application.submitted?
    
    # Make sure we have the right questions sheets from this project
    unless @application.question_sheets.collect(&:id).sort == [@project.basic_info_question_sheet_id, @project.template_question_sheet_id].sort
      @application.answer_sheet_question_sheets.map(&:destroy)
      @application.answer_sheet_question_sheets.create!(:answer_sheet_id => @application.id, :question_sheet_id => @project.basic_info_question_sheet_id)
      @application.answer_sheet_question_sheets.create!(:answer_sheet_id => @application.id, :question_sheet_id => @project.template_question_sheet_id)
      @application.reload
    end
    
    # QE Code
    @answer_sheet = @application 
    @presenter = AnswerPagesPresenter.new(self, @application)
    @elements = @presenter.questions_for_page(:first).elements
    @page = @presenter.pages.first
    @presenter.active_page ||= @page
    raise @application.inspect if @presenter.active_page.nil?
    render 'answer_sheets/edit'
  end
  
  def multiple_projects
    @current_project = @application.project
    @new_project = SpProject.find(params[:p])
  end
  
  def show
    
  end
  protected
    def redirect_to_closed
      unless current_person.isStaff?
        redirect_to :action => :closed 
        return false
      end
    end
    
    def get_application
      if sp_user && sp_user.can_su_application?
        @application = SpApplication.find(params[:id])
      else
        @application = current_person.sp_applications.find(params[:id])
      end
    end
    
    
    def get_answer_sheet
      @answer_sheet = get_application
    end
end
