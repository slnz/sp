class MinistryFilter
  attr_accessor :ministries, :filters

  def initialize(filters)
    @filters = filters || {}

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }
  end

  def filter(ministries)
    filtered_ministries = ministries

    if @filters[:id]
      filtered_ministries = filtered_ministries.where("#{Ministry.table_name}.#{Ministry.primary_key}" => @filters[:id])
    end

    if @filters[:ids]
      filtered_ministries = filtered_ministries.where("#{Ministry.table_name}.#{Ministry.primary_key}" => @filters[:ids].split(',').collect(&:strip))
    end

    if @filters[:name]
      filtered_ministries = filtered_ministries.where("#{Ministry.table_name}.name" => @filters[:name])
    end

    if @filters[:names]
      filtered_ministries = filtered_ministries.where("#{Ministry.table_name}.name" => @filters[:names].split(',').collect(&:strip))
    end

    if @filters[:name_like]
      filtered_ministries = filtered_ministries.where("#{Ministry.table_name}.name LIKE ?", "#{@filters[:name_like]}%")
    end

    filtered_ministries
  end
end