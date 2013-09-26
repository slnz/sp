class Admin::EvaluationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  before_filter :get_evaluation, :only => [:update, :page, :references, :print, :payments]
  before_filter :get_presenter, :only => [:evaluate, :page]
  before_filter :check_access
  layout 'admin'

  def update
    @evaluation.update_attributes(params[:evaluation])
    update_evaluation and return
  end

  def evaluate
    projects_base = SpProject.current.uses_application.order(:name)
    @projects = @person.is_male? ? projects_base.not_full_men : projects_base.not_full_women
    @projects = [@application.project] + @projects if @application.project && !@projects.include?(@application.project)
    @valid_events = @application.next_states_for_events
  end

  def page
    @page = Page.find(params[:page_id])
    @answer_sheet = @application
    @pages = @presenter.pages[0..-2]
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
      @presenter = AnswerPagesPresenter.new(self, @application)
    end
    if params[:references] == 'true'
      set_up_reference_elements
    end
    render :layout => 'print'
  end

  protected
  def update_evaluation
    @project = @application.project
    if params[:event] && params[:event] != ''
      @application.send("#{params[:event]}!".to_sym)
    end
    if params[:application][:project_id].blank?
      flash[:error] = "This applicant must be assigned to a project to be evaluated"
      redirect_to :back and return
    end
    if params[:application][:applicant_notified] == 'true' && !SpApplication.accepted_statuses.include?(@application.status)
      flash[:error] = "You said you notified the application of acceptance, but haven't marked them as accepted yet. Please mark this applicant as accepted."
      redirect_to :back and return
    end
    @application.update_attributes(params[:application])
    redirect_to @project ? admin_project_path(@project) : dashboard_path
  end

  def get_evaluation
    @evaluation = SpEvaluation.includes(:sp_application).find(params[:id])
    @application = @evaluation.sp_application
  end

  def get_presenter
    @application = SpApplication.includes(:person).find(params[:application_id])
    @evaluation = @application.evaluation || SpEvaluation.create(:application_id => @application.id)
    @person = @application.person
    @answer_sheet = @application
    @presenter = AnswerPagesPresenter.new(self, @application)
  end

  def set_up_reference_elements
    @elements = []
    @references = @application.reference_sheets
    @references.reject! {|r| !r.question_sheet}
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

end
