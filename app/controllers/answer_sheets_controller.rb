class AnswerSheetsController < ApplicationController
  include Fe::AnswerSheetsControllerConcern

  prepend_before_filter :login

  def index
    raise ActionController::RoutingError.new('Not Found')
  end

  def show
    raise ActionController::RoutingError.new('Not Found')
  end

  def submit
    session[:attempted_submit] = true
    return false unless validate_sheet
    case @answer_sheet.class.to_s
    when 'SpApplication'
      @answer_sheet.submit!
      # send references 
      @answer_sheet.sp_references.each do |reference| 
        reference.send_invite unless reference.email_sent?
      end
      render 'applications/submitted'
    when 'ReferenceSheet'
      @answer_sheet.submit! unless @answer_sheet.completed?
      render 'reference_sheets/submitted'
    else
      super
    end
    return false
  end
  
  def edit
    @project = @answer_sheet.project
    @presenter = AnswerPagesPresenter.new(self, @answer_sheet, params[:a])
    @elements = @presenter.questions_for_page(:first).elements
    @page = @presenter.pages.first
  end
  
  protected
    # Add some security to this method
    def get_answer_sheet
      @answer_sheet = answer_sheet_type.find(params[:id])
      case @answer_sheet.class.to_s
      when 'SpApplication'
        unless @answer_sheet.person == current_person || (sp_user && sp_user.can_su_application?)
          redirect_to root_path
          return false
        end
      when 'ReferenceSheet'
        
      else
        redirect_to root_path
        return false
      end
          
    end
    
    def login
      ssm_login_required unless answer_sheet_type.to_s == 'ReferenceSheet'
    end
end
