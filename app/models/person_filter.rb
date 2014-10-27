class PersonFilter
  attr_accessor :people, :filters

  def initialize(filters, organization = nil)
    @filters = filters || {}
    @organization = organization

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }

  end

  def filter(people)
    filtered_people = people

    if @filters[:id]
      filtered_people = filtered_people.where("#{Person.table_name}.#{Person.primary_key}" => @filters[:id])
    end

    if @filters[:ids]
      filtered_people = filtered_people.where("#{Person.table_name}.#{Person.primary_key}" => @filters[:ids].split(',').collect(&:strip))
    end

    if @filters[:first_name_like]
      filtered_people = filtered_people.where("first_name like ? ", "#{@filters[:first_name_like]}%")
    end

    if @filters[:last_name_like]
      filtered_people = filtered_people.where("last_name like ? ", "#{@filters[:last_name_like]}%")
    end

    if @filters[:name_or_email_like]
      case
        when @filters[:name_or_email_like].split(/\s+/).length > 1
          # Email addresses don't have spaces, so if there's a space, this is probably a name
          @filters[:name_like] = @filters.delete(:name_or_email_like)
        when @filters[:name_or_email_like].include?('@')
          # Names don't typically have @ signs
          @filters[:email_like] = @filters.delete(:name_or_email_like)
        else
          filtered_people = filtered_people.joins(%|LEFT OUTER JOIN "email_addresses" ON "email_addresses"."person_id" = "ministry_person"."id"|)
          .where("concat(first_name,' ',last_name) LIKE :search OR
                                                  first_name LIKE :search OR last_name LIKE :search OR
                                                  email_addresses.email LIKE :search",
                 {:search => "#{filters[:name_or_email_like]}%"})
      end
    end

    if @filters[:name_like]
      # See if they've typed a first and last name
      if @filters[:name_like].split(/\s+/).length > 1
        filtered_people = filtered_people.where("concat(first_name,' ',last_name) like ? ", "%#{@filters[:name_like]}%")
      else
        filtered_people = filtered_people.where("first_name like :search OR last_name like :search",
                                                {search: "#{@filters[:name_like]}%"})
      end
    end

    if @filters[:email_like]
      filtered_people = filtered_people.joins(%|LEFT OUTER JOIN "email_addresses" ON "email_addresses"."person_id" = "ministry_person"."id" |)
      .where("email_addresses.email LIKE :search",
             {:search => "#{filters[:name_or_email_like]}%"})
    end

    if @filters[:gender]
      filtered_people = filtered_people.where(gender: @filters[:gender].to_s)
    end

    if @filters[:strategy]
      filtered_people = filtered_people.where('strategy' => @filters[:strategy].split(',').collect(&:strip))
    end

    filtered_people
  end
end
