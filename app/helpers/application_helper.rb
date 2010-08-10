module ApplicationHelper
  def embed_params
    ret = <<-END
      <script type="text/javascript" charset="utf-8">
        params = #{params.to_json};
      </script>
    END
    ret.html_safe
  end
end
