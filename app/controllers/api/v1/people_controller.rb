class Api::V1::PeopleController < Api::V1::BaseController
  def index
    order = params[:order] || 'last_name, first_name'

    filtered_people = Person.where("first_name is not null and first_name <> ''")
    filtered_people = filtered_people.not_secure unless params[:include_secure] == 'true'
    filtered_people = PersonFilter.new(params[:filters]).filter(filtered_people)

    render render_options(filtered_people, order)
  end

  def show
    person = Person.find(params[:id])
    render render_options(person)
  end

  private

  def available_includes
    [:current_address, :email_addresses, :phone_numbers]
  end
end
