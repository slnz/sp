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
end
