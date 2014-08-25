module ProjectsHelper
  PartnershipOption = Struct.new(:id, :name)
  class PartnershipType
    attr_accessor :type_name, :options
    def initialize(name)
      @type_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end
  end

  # This method was written by Isaac Kimball
  def stat_link(project, project_version,text, options = {})
    pb = Time.now.to_date
    pe = Time.now.to_date
    statLink = ""
    if Rails.env.development?
      statLink="http://info.int.uscm.org/stats/sp"
    elsif Rails.env.production?
      statLink="https://infobase.uscm.org/stats/sp"
    else
      statLink="http://localhost:3000/stats/sp"
    end
    if project_version.id.to_s == project.id.to_s
      statLink = statLink + "?name=" + project_version.name
      statLink = statLink + "&region=" + project_version.primary_partner
      statLink = statLink + "&strategy="
      statLink = statLink + "WS" if project_version.report_stats_to == 'Campus Ministry - Global Missions summer project'
      statLink = statLink + "&email="
      if project_version.pd
        if project_version.pd_email
          statLink = statLink + project_version.pd_email
        end
      end
      statLink=statLink+"&isSecure="+(project_version.country_status=='open' ? "F":"T")

      statLink=statLink+"&periodBegin="
      if project_version.start_date && project_version.date_of_departure
        if project_version.start_date > project_version.date_of_departure
          pb = project_version.start_date
        else
          pb = project_version.date_of_departure
        end
      elsif project_version.start_date
        pb = project_version.start_date
      elsif project_version.date_of_departure
        pb = project_version.date_of_departure
      end
      statLink=statLink + pb.to_s

      statLink= statLink + "&periodEnd="
      if project_version.end_date && project_version.date_of_return
        if project_version.end_date < project_version.date_of_return
          pe = project_version.end_date
        else
          pe = project_version.date_of_return
        end
      elsif project_version.end_date
        pe = project_version.end_date
      elsif project_version.date_of_return
        pe = project_version.date_of_return
      end
      statLink = statLink + pe.to_s
      statLink = statLink + "&redirect=https://" + request.host + "%2Fadmin%2Fprojects%2F" + project.id.to_s + "&eventKeyID=" + project_version.id.to_s
      statLink = link_to(text, statLink, options.merge({:target => '_blank'}))
      statLink

    end

  end

  def partnership_select(object, method, options = nil, html_options = {})
    unless options && options.include?(:no_object_tag)
      html_options["name"] ||= "sp_project[#{method.to_s}]"
      html_options["id"] ||= "sp_project_#{method.to_s}"
    else
      html_options["name"] ||= method
      html_options["id"] ||= method
    end
    none = PartnershipType.new('None')
    none << PartnershipOption.new('','')
    collections = [none]
    if !options || options.include?(:regions)
      region = PartnershipType.new('Region')
      @regions ||= Region.all
      @regions.each {|r| region << PartnershipOption.new(r.region, r.name) unless r.region.empty?}
      collections << region
    end
    if !options || options.include?(:ministries)
      ministry = PartnershipType.new('Ministry')
      @ministries ||= Ministry.where("name <> 'Campus Ministry'").order("name")
      @ministries.each {|m| ministry << PartnershipOption.new(m.name, m.name)}
      collections << ministry
    end
    if !options || options.include?(:teams)
      team = PartnershipType.new('Team')
      @teams ||= Team.get('filters[lane]' => 'SC,CA', 'filters[country]' => 'USA')
      @teams.each {|t| team << PartnershipOption.new(t.name, t.name) unless t.name.empty?}
      collections << team
    end
    record = instance_variable_get("@#{object}")
    tag = content_tag("select", option_groups_from_collection_for_select(collections, :options, :type_name, :id, :name, eval("@#{object}.#{method}")), html_options)
    tag = error_wrapping(tag, record.errors[method]) unless options && options.include?(:no_errors)
  end

  def error_wrapping(html_tag, has_error)
    has_error ? ActionView::Base.field_error_proc.call(html_tag, self) : html_tag
  end

  def highlight_date(app, date_field)
    app.read_attribute(date_field).present? ? "highlight" : ""
  end
end
