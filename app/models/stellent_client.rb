class StellentClient

  def client
    @client ||= Savon.client do
      endpoint APP_CONFIG['stellent_endpoint']
      namespace 'http://www.stellent.com/CheckIn/'
      basic_auth APP_CONFIG['stellent_username'], APP_CONFIG['stellent_password']
      ssl_verify_mode :none
    end
  end

  def push_to_stellent(app)
    @app = app
    check_out
    check_in
  end

  def check_out
    attrs = attributes
    client.call('CheckOutByName', message: attrs.slice(:d_doc_name))
  end

  def check_in
    client.call('CheckInUniversal', message: attributes)
  end

  private

  def attributes
    designation_number = @app.get_designation_number
    @attrs ||= {
      d_doc_name: 'DSS_STAFF_' + designation_number,
      d_doc_title: @app.person.informal_full_name,
      d_doc_type: 'WebContent',
      d_doc_author: 'summermissionsadmin',
      d_security_group: 'Public',
      d_doc_account: 'Shared-dss-staff-' + designation_number,
      primary_file: {
        file_name: designation_number + '-content.xml',
        file_content: Base64.encode64(xml(@app).gsub("\n",'').strip).gsub("\n",'')
      },
      extra_props: {
        property: [
          { name: 'xHidden', value: 'FALSE' },
          { name: 'xRegionDefinition', value: 'RD_GIVE_STUDENT' },
          { name: 'xSearchable', value: 'Yes' },
          { name: 'xWebsites', value: 'Give' },
          { name: 'xFriendlyFilename', value: designation_number },
          { name: 'xWebsiteObjectType', value: 'Data File' },
          { name: 'xLanguage', value: 'English' },
          { name: 'xSiebelDesignation', value: designation_number }
        ]
      }
    }
  end

  def xml(app)
    picture = app.project.picture_file_name ? clean('<img src="' + app.project.picture.url + '" />') : ''
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <wcm:root xmlns:wcm="http://www.stellant.com/wcm-data/ns/8.0.0" version="8.0.0.0">
      <wcm:element name="title">#{clean(app.person.informal_full_name)}</wcm:element>
      <wcm:element name="body">#{clean('<p>' + app.project.full_project_description.gsub(/\n/, '<br>') + '</p>')}</wcm:element>
      <wcm:element name="show_homepage_headlines">true</wcm:element>
      <wcm:element name="show_page_tools">true</wcm:element>
      <wcm:element name="disable_facebook_comments">true</wcm:element>
      <wcm:element name="wide_image"></wcm:element>
      <wcm:element name="default_summer_image">#{picture}</wcm:element>
      <wcm:element name="use_default_summer_image">true</wcm:element>
      </wcm:root>
    EOF
  end

  def clean(s)
    CGI.escapeHTML(s)
  end
end
