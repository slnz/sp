module ERB::Util
  def html_escape(s)
    s = s.to_s
    s = s.force_encoding("utf-8") if s.respond_to?(:force_encoding) && !s.frozen?
    if s.html_safe?
      s
    else
      s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }.html_safe
    end
  end
end