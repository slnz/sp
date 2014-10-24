class ProjectFilter
  attr_accessor :projects, :filters

  def initialize(filters)
    @filters = filters || {}

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }
  end

  def filter(projects)
    filtered_projects = projects

    if @filters[:id]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.#{SpProject.primary_key}" => @filters[:id])
    end

    if @filters[:ids]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.#{SpProject.primary_key}" => @filters[:ids].split(',').collect(&:strip))
    end

    if @filters[:name]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.name" => @filters[:name])
    end

    if @filters[:name_like]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.name LIKE ?", "#{@filters[:name_like]}%")
    end

    if @filters[:status]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.project_status" => @filters[:status].split(',').collect(&:strip))
    end

    if @filters[:year]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.year" => @filters[:year].split(',').collect(&:strip))
    end

    if @filters[:primary_partner]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.primary_partner" => @filters[:primary_partner].split(',').collect(&:strip))
    end

    if @filters[:not_primary_partner]
      filtered_projects = filtered_projects.where("#{SpProject.table_name}.primary_partner NOT IN (?)", @filters[:not_primary_partner].split(',').collect(&:strip))
    end

    filtered_projects
  end
end
