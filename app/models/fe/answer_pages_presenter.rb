module Fe
  class AnswerPagesPresenter < Presenter
    include AnswerPagesPresenterConcern

    def initialize_pages(answer_sheet)
      @pages = []
      answer_sheet.question_sheets.each do |qs|
        qs.pages.visible.each do |page|
          @pages << page
        end
      end
      # specify the order of the top 3 pages
      ['Instructions', 'Basic Information', 'Passport Information'].each_with_index do |page_name, i|
        index = @pages.index { |p| p.label == page_name }
        if index
          page = @pages.delete_at(index)
          @pages.insert(i, page) if page
        end
      end

      if answer_sheet.respond_to?(:project)
        if answer_sheet.project && answer_sheet.project.project_specific_question_sheet &&
           answer_sheet.project.project_specific_question_sheet.pages.first &&
           answer_sheet.project.project_specific_question_sheet.pages.first.elements.count > 0
          begin
            @pages.insert(-2, answer_sheet.project.project_specific_question_sheet.pages.first)
          rescue IndexError
            @pages << answer_sheet.project.project_specific_question_sheet.pages.first
          end
        end
      end
      @pages
    end
  end
end
