module ProjectsHelper
  def stat_link(project, project_version,text, options = {})
    pb=Time.now.to_date
    pe=Time.now.to_date
    statLink = ""
    if Rails.env.development?
      statLink="https://staff.int.campuscrusadeforchrist.com/servlet/InfoBaseController?action=enterEventSuccessCriteria&eventType=SP"
    elsif Rails.env.production?
      statLink="https://staff.campuscrusadeforchrist.com/servlet/InfoBaseController?action=enterEventSuccessCriteria&eventType=SP"
    else
      statLink="http://localhost:8080/servlet/InfoBaseController?action=enterEventSuccessCriteria&eventType=SP"
    end
    if project_version.id.to_s==project.id.to_s
      statLink=statLink+"&name="+project_version.name
      statLink=statLink+"&region="+project_version.primary_partner
      statLink=statLink+"&strategy="
      statLink=statLink+"&email="
      if project_version.pd
        if project_version.pd_email
          statLink=statLink+project_version.pd_email
        end
      end
      statLink=statLink+"&isSecure="+(project_version.country_status=='open' ? "F":"T")

      statLink=statLink+"&periodBegin="
      if project_version.start_date && project_version.date_of_departure
        if project_version.start_date>project_version.date_of_departure
          pb=project_version.start_date.to_s
        else
          pb=project_version.date_of_departure.to_s
        end
      elsif project_version.start_date
        pb=project_version.start_date.to_s
      elsif project_version.date_of_departure
        pb=project_version.date_of_departure.to_s

      end
      statLink=statLink+pb.to_time.to_i.to_s+"000"

      statLink=statLink+"&periodEnd="
      if project_version.end_date && project_version.date_of_return
        if project_version.end_date<project_version.date_of_return
          pe=project_version.end_date.to_s
        else
          pe=project_version.date_of_return.to_s
        end
      elsif project_version.end_date
        pe=project_version.end_date.to_s
      elsif project_version.date_of_return
        pe=project_version.date_of_return.to_s
      end
      statLink=statLink+pe.to_time.to_i.to_s+"000"
      statLink=statLink+"&redirect="+request.host+"%2Fprojects%2F"+project.id.to_s+"%2Froster&eventKeyID="+project_version.id.to_s
      statLink= link_to(text, statLink, options.merge({:target => '_blank'}))
      statLink

    end

  end
end
