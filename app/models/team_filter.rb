class TeamFilter
  attr_accessor :teams, :filters

  def initialize(filters)
    @filters = filters || {}

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }
  end

  def filter(teams)
    filtered_teams = teams

    if @filters[:id]
      filtered_teams = filtered_teams.where("#{Team.table_name}.#{Team.primary_key}" => @filters[:id])
    end

    if @filters[:ids]
      filtered_teams = filtered_teams.where("#{Team.table_name}.#{Team.primary_key}" => @filters[:ids].split(',').collect(&:strip))
    end

    if @filters[:name]
      filtered_teams = filtered_teams.where("#{Team.table_name}.name like ?", "%#{@filters[:name]}%")
    end

    if @filters[:region]
      filtered_teams = filtered_teams.where("#{Team.table_name}.region" => @filters[:region])
    end

    if @filters[:lane]
      filtered_teams = filtered_teams.where("#{Team.table_name}.region" => @filters[:lane])
    end

    if @filters[:lanes]
      filtered_teams = filtered_teams.where("#{Team.table_name}.region" => @filters[:lanes].split(',').collect(&:strip))
    end

    if @filters[:country]
      filtered_teams = filtered_teams.where("#{Team.table_name}.region" => @filters[:country])
    end

    filtered_teams
  end
end