class ApplicationsController < Fe::AnswerSheetsController
  prepend_before_filter :ssm_login_required, except: [:closed]
  before_action :get_application, only: [:multiple_projects, :done, :edit, :show]

  def closed
    @project = SpProject.find(params[:id]) if params[:id]
    render layout: false
  end

  def index
    redirect_to '/'
  end

  def apply
    session[:attempted_submit] = nil
    @project = SpProject.uses_application.find_by_id(params[:p]) if params[:p]
    if @project && !@project.current?
      redirect_to(action: :closed, id: @project.id) && return
    end
    # If the current user has already started an application, pick it up from there
    @application = current_person.sp_applications.last

    if @application && @application.year == @application.project.try(:year)
      if @project
        # They are switching projects
        if params[:force] == 'true'
          @application.update_attribute(:project_id, params[:p])
          # Do a redirect to reset variables
          redirect_to apply_path
          return false
        else
          # If they alreay started an appliation for another project, and are now trying to do this one, we need to ask them what to do
          if @application.project.present? && @application.project != @project
            redirect_to multiple_projects_application_path(@application, p: params[:p])
            return false
          end
        end
      end

      @project ||= @application.project
    else
      if @project
        @application = current_person.sp_applications.where(project_id: @project.id, year: @project.year).first
        @application ||= current_person.sp_applications.create!(project_id: @project.id, year: @project.year)
      else
        redirect_to projects_path
        return false
      end
    end

    # Make sure we have the right questions sheets from this project
    unless @application.question_sheets.collect(&:id).sort == [@project.basic_info_question_sheet_id, @project.template_question_sheet_id].sort
      @application.answer_sheet_question_sheets.map(&:destroy)
      @application.answer_sheet_question_sheets.create!(answer_sheet_id: @application.id, question_sheet_id: @project.basic_info_question_sheet_id)
      @application.answer_sheet_question_sheets.create!(answer_sheet_id: @application.id, question_sheet_id: @project.template_question_sheet_id)
      @application.reload
      @answer_sheet = @application
    end

    # If they've submitted their application, go to the status page
    if @application.frozen?
      redirect_to(application_path(@application)) && return
    end

    # QE Code
    @answer_sheet = @application
    @presenter = Fe::AnswerPagesPresenter.new(self, @application)
    @elements = @presenter.questions_for_page(:first).elements
    @page = @presenter.pages.first
    @presenter.active_page ||= @presenter.new_page_link(@answer_sheet, @page)
    render 'answer_sheets/edit'
  end

  def multiple_projects
    @current_project = @application.project
    @new_project = project_base.find(params[:p])
  end

  def show
  end

  def edit
    super
    @project = @application.project
    render 'answer_sheets/edit'
  end

  protected

  def get_application
    if sp_user && sp_user.can_su_application?
      @answer_sheet = @application = SpApplication.find(params[:id])
    else
      @answer_sheet = @application = current_person.sp_applications.find(params[:id])
    end
  end

  def get_answer_sheet
    @answer_sheet = get_application
  end

  def project_base
    SpProject.uses_application.current
  end
end
