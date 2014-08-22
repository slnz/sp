class TargetArea
  def initialize(target_area)
    @target_area = target_area
  end

  def teams
    @target_area['teams']
  end

  def self.get(params)
    new(Infobase::TargetArea.get(params)['target_areas'].first)
  end

  def [](key)
    @target_area[key]
  end

  def team_name
    teams.first['name'] if teams.present?
  end
end
