require_dependency Rails.root.join('vendor','plugins','questionnaire_engine','app','controllers','answer_sheets_controller').to_s
class AnswerSheetsController < ApplicationController
  before_filter :ssm_login_required
  
  def submit
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
      @answer_sheet.submit!
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
        unless @answer_sheet.person == current_person
          redirect_to root_path
          return false
        end
      when 'ReferenceSheet'
        
      else
        redirect_to root_path
        return false
      end
          
    end
end