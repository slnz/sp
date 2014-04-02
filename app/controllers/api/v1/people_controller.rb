class Api::V1::PeopleController < Api::V1::BaseController

  def index
    order = params[:order] || 'lastName, firstName'

    filtered_people = Person.where("firstName is not null and firstName <> ''")
    filtered_people = filtered_people.not_secure unless params[:include_secure] == 'true'
    filtered_people = PersonFilter.new(params[:filters]).filter(filtered_people)

    render render_options(filtered_people, order)
  end

  private

  def available_includes
    [:current_address, :email_addresses, :phone_numbers]
  end

end
