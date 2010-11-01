require_dependency Rails.root.join('vendor','plugins','questionnaire_engine','app','presenters','answer_pages_presenter').to_s
class AnswerPagesPresenter < Presenter
  def initialize_pages(answer_sheet)
    @pages = []
    answer_sheet.question_sheets.each do |qs|
      qs.pages.visible.each do |page|
        @pages << page
      end
    end
    # put the instructions page first
    index = @pages.index {|p| p.label == 'Instructions'} 
    instructions = @pages.delete_at(index)
    @pages.insert(0, instructions) if instructions
    
    if answer_sheet.project.project_specific_question_sheet && answer_sheet.project.project_specific_question_sheet.pages.first && answer_sheet.project.project_specific_question_sheet.pages.first.elements.present?
      @pages.insert(-2, answer_sheet.project.project_specific_question_sheet.pages.first)
    end
    @pages
  end
end