class Admin::EvaluationsController < ApplicationController
  before_action :cas_filter, :authentication_filter
  before_action :get_evaluation, only: [:update, :page, :references, :print, :payments]
  before_action :get_presenter, only: [:evaluate, :page]
  before_action :check_access
  layout 'admin'

  def update
    @evaluation.update_attributes(evaluation_params)
    update_evaluation && return
  end

  def evaluate
    projects_base = SpProject.open.uses_application.order(:name)
    @projects = @person.is_male? ? projects_base.not_full_men : projects_base.not_full_women
    @projects = [@application.project] + @projects if @application.project && !@projects.include?(@application.project)
    @valid_events = @application.next_states_for_events
  end

  def page
    @page = Fe::Page.find(params[:page_id])
    @answer_sheet = @application
    @pages = @presenter.pages[0..-2]
    @pages.reject! { |page| !page.has_questions? }
    @next_page = @pages[@pages.index(@page) + 1]
  end

  def references
    # Collect all questions asked for consolidated display of answers
    set_up_reference_elements
  end

  def payments
  end

  def print
    @person = @application.person
    @answer_sheet = @application
    if params[:application] == 'true'
      @presenter = Fe::AnswerPagesPresenter.new(self, @application)
    end
    if params[:references] == 'true'
      set_up_reference_elements
    end
    render layout: 'print'
  end

  protected

  def update_evaluation
    @project = @application.project
    if event_param && event_param != ''
      @application.send("#{event_param}!".to_sym) if @application.send("may_#{event_param}?".to_sym)
    end
    if application_params[:project_id].blank?
      flash[:error] = 'This applicant must be assigned to a project to be evaluated'
      redirect_to(:back) && return
    end
    if application_params[:applicant_notified] == 'true' && !SpApplication.accepted_statuses.include?(@application.status)
      flash[:error] = "You said you notified the application of acceptance, but haven't marked them as accepted yet. Please mark this applicant as accepted."
      redirect_to(:back) && return
    end
    @application.update_attributes(application_params)
    redirect_to @project ? admin_project_path(@project) : dashboard_path
  end

  def get_evaluation
    @evaluation = SpEvaluation.includes(:sp_application).find(params[:id])
    @application = @evaluation.sp_application
  end

  def get_presenter
    @application = SpApplication.includes(:person).find(params[:application_id])
    @evaluation = @application.evaluation || SpEvaluation.create(application_id: @application.id)
    @person = @application.person
    @answer_sheet = @application
    @presenter = Fe::AnswerPagesPresenter.new(self, @application)
  end

  def set_up_reference_elements
    @elements = []
    @references = @application.reference_sheets.to_a
    @references.reject! { |r| !r.question_sheet }
    @references.each do |reference|
      @elements = @elements | reference.question_sheet.elements
    end
  end

  def check_access
    if params[:application_id] && !@application
      @application = SpApplication.find(params[:application_id])
    end
    unless sp_user && sp_user.can_evaluate_applicant?(@application)
      flash[:error] = "You don't have permission to evaluate that applicant"
      redirect_to '/admin' and return false
    end
  end

  def evaluation_params
    params.require(:evaluation).permit(:spiritual_maturity, :teachability, :leadership, :stability, :good_evangelism, :reason, :social_maturity, :ccc_involvement, :charismatic, :morals, :drugs, :bad_evangelism, :authority, :eating, :comments)
  end

  def application_params
    params.require(:application).permit(:project_id, :designation_number, :year, :status, :preference1_id, :preference2_id, :preference3_id, :preference4_id, :preference5_id, :current_project_queue_id, :apply_for_leadership, :applicant_notified, :previous_status, :rm_liability_signed)
  end

  def event_param
    params.permit(:event)[:event]
  end
end
