namespace :gcx do
  task create: :environment do
    project = SpProject.find(ENV['PROJECT_ID'])
    year = ENV['YEAR'] || SpApplication.year
    applications = project.sp_applications.for_year(year).joins(:person).includes({:person => :current_address}).order('last_name, first_name')
    (applications.accepted_participants + applications.accepted_student_staff).each do |application|
      person = application.person

      # First make sure every student has a relay account.
      unless person.user.globallyUniqueID.present?
        password = SecureRandom.hex(5)
        person.user.password_plain = password
        person.user.globallyUniqueID = RelayApiClient::Base.create_account(person.email_address, password, person.nickname, personlast_namee)
        person.user.save(validate: false)
        puts "Relay account created: #{person.user.globallyUniqueID}"
      end

      # make sure we have the right username
      l = IdentityLinker::Linker.find_linked_identity('ssoguid',person.user.globallyUniqueID,'username')
      username = l[:identity][:id_value]
      if username != person.user.username
        person.user.username = username
        person.user.save
      end

      # Try to create a unique gcx community
      unless person.sp_gcx_site.present?
        name = person.informal_full_name.downcase.gsub(/\s+/,'-').gsub(/[^a-z0-9_\-]/,'')
        site_attributes = {name: name, title: 'My Summer Project', privacy: 'public', theme: 'cru-spkick', sitetype: 'campus'}
        site = GcxApi::Site.new(site_attributes)
        unless site.valid?
          # try a different name
          site_attributes[:name] += '-' + project.state.downcase
          site = GcxApi::Site.new(site_attributes)

          raise site.errors.full_messages.inspect unless site.valid?
        end
        puts site_attributes[:name].inspect

        site.create

        person.update_attributes(sp_gcx_site: site_attributes[:name])

        puts "Created #{site_attributes[:name]}"

        GcxApi::User.create(person.sp_gcx_site, [{relayGuid: person.user.globallyUniqueID, role: 'administrator'}])
      end

    end
  end
end
