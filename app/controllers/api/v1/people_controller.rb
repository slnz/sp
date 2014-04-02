class Api::V1::PeopleController < Api::V1::BaseController

  def index
    order = params[:order] || 'lastName, firstName'

    filtered_people = Person.where("firstName is not null and firstName <> ''")
    filtered_people = filtered_people.not_secure unless params[:include_secure] == 'true'
    filtered_people = PersonFilter.new(params[:filters]).filter(filtered_people)

    render render_options(filtered_people, order)
  end

  def is_staff
    results, people = {}, {}

    person_ids = params[:people].split(',')
    Person.where(personID: person_ids).collect {|p| people[p.id] = p}
    person_ids.each do |id|
      if p = people[id.to_i]
        results[id] = p.isStaff?
      else
        results[id] = nil
      end
    end

    render json: {people: results}
  end

  private

  def available_includes
    [:current_address, :email_addresses, :phone_numbers]
  end

end
