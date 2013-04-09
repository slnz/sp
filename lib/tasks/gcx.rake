namespace :gcx do
  task create: :environment do
    project = SpProject.find(ENV['PROJECT_ID'])
    year = ENV['YEAR'] || SpApplication.year
    applications = project.sp_applications.for_year(year).joins(:person).includes({:person => :current_address}).order('lastName, firstName')
    (applications.accepted_participants + applications.accepted_student_staff).each do |application|
      person = application.person
      # Try to create a unique gcx community
      unless person.sp_gcx_site.present?
        name = person.informal_full_name.downcase.gsub(/\s+/,'-').gsub(/[^a-z0-9_\-]/,'')
        site_attributes = {name: name, title: 'My Summer Project', privacy: 'public', theme: 'cru-spkick'}
        site = GcxApi::Site.new(site_attributes)
        unless site.valid?
          # try a different name
          site_attributes[:name] += '-' + project.state.downcase
          site = GcxApi::Site.new(site_attributes)

          raise site.errors.full_messages.inspect unless site.valid?
        end

        site.create

        person.update_attributes(sp_gcx_site: site_attributes[:name])

      end
      email = 'josh.starcher@gmail.com' #person.email_address
      GcxApi::User.create(person.sp_gcx_site, [{email: email, role: 'administrator'}])
    end
  end
end
