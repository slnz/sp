module ApplicationHelper
  def embed_params(include_action = false)
    params_to_js = params.dup
    unless include_action
      params_to_js.delete(:action)
      params_to_js.delete(:controller)
    end
    ret = <<-END
      <script type="text/javascript" charset="utf-8">
        params = #{params_to_js.to_json};
      </script>
    END
    ret.html_safe
  end
  
  # Creates a link that alternates between acending and descending. It basically
  # alternates between calling 2 named scopes: "ascend_by_*" and "descend_by_*"
  #
  # By default Searchlogic gives you these named scopes for all of your columns, but
  # if you wanted to create your own, it will work with those too.
  #
  # Examples:
  #
  #   order @search, :by => :username
  #   order @search, :by => :created_at, :as => "Created"
  #
  # This helper accepts the following options:
  #
  # * <tt>:by</tt> - the name of the named scope. This helper will prepend this value with "ascend_by_" and "descend_by_"
  # * <tt>:as</tt> - the text used in the link, defaults to whatever is passed to :by
  # * <tt>:ascend_scope</tt> - what scope to call for ascending the data, defaults to "ascend_by_:by"
  # * <tt>:descend_scope</tt> - what scope to call for descending the data, defaults to "descend_by_:by"
  # * <tt>:params</tt> - hash with additional params which will be added to generated url
  # * <tt>:params_scope</tt> - the name of the params key to scope the order condition by, defaults to :search
  def order(search, options = {}, html_options = {})
    options[:params_scope] ||= :search
    if !options[:as]
      id = options[:by].to_s.downcase == "id"
      options[:as] = id ? options[:by].to_s.upcase : options[:by].to_s.humanize
    end
    options[:ascend_scope] ||= "ascend_by_#{options[:by]}"
    options[:descend_scope] ||= "descend_by_#{options[:by]}"
    ascending = search.order.to_s == options[:ascend_scope]
    new_scope = ascending ? options[:descend_scope] : options[:ascend_scope]
    selected = [options[:ascend_scope], options[:descend_scope]].include?(search.order.to_s)
    if selected
      css_classes = html_options[:class] ? html_options[:class].split(" ") : []
      if ascending
        options[:as] = "&#9650;&nbsp;#{options[:as]}"
        css_classes << "ascending"
      else
        options[:as] = "&#9660;&nbsp;#{options[:as]}"
        css_classes << "descending"
      end
      html_options[:class] = css_classes.join(" ")
    end
    url_options = {
      options[:params_scope] => search.conditions.merge( { :order => new_scope } )
    }.deep_merge(options[:params] || {})

    options[:as] = raw(options[:as]) if defined?(RailsXss)

    link_to options[:as], url_for(url_options), html_options
  end
  
  def sort_by(column, title = column.titleize, options = {})
    if title.is_a?(Hash)
      options = title 
      title = column.titleize
    end
    if params[:order] == column
      if params[:direction] == 'ascend'
        title = "&#9650;&nbsp;#{title}"
      else
        title = "&#9660;&nbsp;#{title}"
      end
    end
    ordered = params.dup
    ordered[:direction] = (ordered[:order] == column && ordered[:direction] == 'ascend') ? 'descend' : 'ascend'
    ordered[:order] = column
    
    link_to(title.html_safe, ordered)
  end
  
  def spinner(extra = nil)
    e = extra ? "spinner_#{extra}" : 'spinner'
    image_tag('spinner.gif', :id => e, :style => 'display:none', :class => 'spinner')
  end
  
  def calendar_date_select_tag(name, value = nil, options = {})
    options.merge!({'data-calendar' => true})
    text_field_tag(name, value, options )
  end
  
end
