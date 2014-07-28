class Region
  cattr_reader :standard_region_codes, :campus_region_codes
  @@standard_region_codes = ["GL", "GP", "MA", "MS", "NE", "NW", "RR", "SE", "SW", "UM"]
  @@campus_region_codes = @@standard_region_codes.clone << "NC"
  attr_accessor :teamID, :name, :note, :region, :address1, :address2, :city, :state, :zip, :country, :phone,
    :fax, :email, :url, :isActive, :startdate, :stopdate, :no, :abbrv, :hrd, :spPhone, :global_registry_id

  def initialize(region)
    region.each { |k, v| self.send(k.to_sym, v) }
  end

  def self.standard_regions
    all_regions.select_all { |r| @@standard_region_codes.include?(r.region) }
  end

  def self.campus_regions
    all_regions.select_all { |r| @@campus_region_codes.include?(r.region) }
  end

  def self.standard_regions_hash
    result = {}
    standard_regions.each do |region|
      result[region.name] = region.region
    end
    result
  end

  def self.full_name(region)
    region = find_by_region(region)
    if region
      region.name
    elsif region == "nil"
      "Unspecified Region"
    else
      ""
    end
  end

  def self.all_regions
    cache(:fetch, :all_regions, expires_in: 1.day) do
      Infobase::Region.get()['regions'].map { |r| Region.new(r) }
    end
  end

  def self.find_by_region(region)
    all_regions.detect { |r| r.region == region }
  end

  def sp_phone
    @sp_phone ||= spPhone.blank? ? phone : spPhone
  end

  def to_s
    region
  end
end
