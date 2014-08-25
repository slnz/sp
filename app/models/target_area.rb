class TargetArea
  ATTRIBUTES = %w(id name type longitude latitude enrollment region state)

  def initialize(target_area = {})
    @target_area = target_area || {}
  end

  def teams
    @teams ||= Infobase::Team.get('filters[target_area_id]' => id) if id
  end

  def self.find_by(params)
    filter_params = {}
    params.each do |k, v|
      filter_params["filters[#{k}]"] = v
    end
    new(Infobase::TargetArea.get(filter_params).first)
  end

  def [](key)
    @target_area[key]
  end

  def team_name
    @team_name ||= teams.first['name'] if teams.present?
  end

  def method_missing(symbol, &block)
    key = symbol.to_s

    return @target_area[key] if ATTRIBUTES.include?(key)

    super
  end
end
