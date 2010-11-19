class Admin::EvaluationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  layout 'admin'
  # def new
  # end
  # 
  # def edit
  # end

  def update
    @evaluation = SpEvaluation.includes(:sp_application).find(params[:id])
    @evaluation.update_attributes(params[:evaluation])
    @application = @evaluation.sp_application
    update_evaluation and return
  end

  def create
    @application = SpApplication.find(params[:application_id])
    @evaluation = @application.create_evaluation(params[:evaluation])
    update_evaluation and return
  end
  
  def evaluate
    @application = SpApplication.includes(:person).find(params[:application_id])
    @evaluation = @application.evaluation || SpEvaluation.new
    @person = @application.person
    @answer_sheet = @application 
    @presenter = AnswerPagesPresenter.new(self, @application)
    projects_base = SpProject.current.uses_application.order(:name)
    @projects = @person.is_male? ? projects_base.not_full_men : projects_base.not_full_women
    @projects = [@application.project] + @projects if @application.project && !@projects.include?(@application.project)
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
      log_changed_project
      redirect_to @project ? admin_project_path(@project) : dashboard_path
    end
    def log_changed_project
      if @project && params[:application][:project_id].to_i != @project.id
        SpApplicationMove.create!(:application_id => @application.id, :old_project_id => @project.id, :new_project_id => @application.project.id,
                                        :moved_by_person_id => current_person.id)
        if new_contact = @application.project.contact
          Notifier.notification(new_contact.email, # RECIPIENTS
                                Questionnaire.from_email, # FROM
                                "Application Moved", # LIQUID TEMPLATE NAME
                                {'applicant_name' => @application.name,
                                 'moved_by' => current_person.informal_full_name}).deliver
        end
    end
  end

end
