require 'spec_helper'

describe Person do
  context '#emergency_address' do
    it 'should set the emergency address' do
      p = create(:person)
      new_emergency_address = create(:fe_address, address_type: 'emergency1')
      p.emergency_address = new_emergency_address
      expect(p.emergency_address).to be(new_emergency_address)
    end
  end

  context '#create_emergency_address' do
    it 'should create the emergency address' do
      p = create(:person)
      expect(p.emergency_address).to be_nil
      p.create_emergency_address
      p.reload
      expect(p.emergency_address).to_not be_nil
      expect(p.emergency_address.address_type).to eq('emergency1')
    end
  end

  context '#create_current_address' do
    it 'should create the current address' do
      p = create(:person)
      expect(p.current_address).to be_nil
      p.create_current_address
      p.reload
      expect(p.current_address).to_not be_nil
      expect(p.current_address.address_type).to eq('current')
    end
  end

  context '#create_permanent_address' do
    it 'should create the permanent address' do
      p = create(:person)
      expect(p.permanent_address).to be_nil
      p.create_permanent_address
      p.reload
      expect(p.permanent_address).to_not be_nil
      expect(p.permanent_address.address_type).to eq('permanent')
    end
  end

  context '#region' do
    it 'should return the right region when region is already set' do
      p = create(:person, region: 'RGN')
      expect(p.region).to eq('RGN')
    end

    it 'should return the right region when the campus is set' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=UW&filters%5Bstate%5D=MN')
        .to_return(status: 200, body: '{"target_areas":[{"name":"UW", "state": "MN", "region": "GL"}]}', headers: {})
      p = create(:person, universityState: 'MN', campus: 'UW')
      expect(p.region).to eq('GL')
    end
  end

  context '#target_area' do
    it 'should use the school if present' do
      p = create(:person, region: 'RGN', school: 'UW')
      expect(p.target_area).to eq('UW')
    end
    it 'should use the target area found by state if universityState is set' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=UW&filters%5Bstate%5D=MN')
        .to_return(status: 200, body: '{"target_areas":[{"name":"UW", "state": "MN", "region": "GL"}]}', headers: {})
      p = create(:person, universityState: 'MN', campus: 'UW')
      expect(p.target_area['name']).to eq('UW')
      expect(p.target_area['state']).to eq('MN')
      expect(p.target_area['region']).to eq('GL')
    end
    it 'should use the target area found only by name if no universityState' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=UW')
        .to_return(status: 200, body: '{"target_areas":[{"name":"UW", "region": "GL"}]}', headers: {})
      p = create(:person, campus: 'UW')
      expect(p.target_area['name']).to eq('UW')
      expect(p.target_area['region']).to eq('GL')
    end
  end

  context '#human_gender' do
    it 'should return empty string if no gender is set' do
      p = create(:person)
      expect(p.human_gender).to eq('')
    end
    it 'should return male if person is male' do
      p = create(:person, gender: '1')
      expect(p.human_gender).to eq('Male')
    end
    it 'should return male if person is female' do
      p = create(:person, gender: '0')
      expect(p.human_gender).to eq('Female')
    end
  end

  context '#is_male?' do
    it 'should return male for integer 1' do
      p = create(:person, gender: 1)
      expect(p.is_male?).to be true
    end
    it 'should return male for string 1' do
      p = create(:person, gender: '1')
      expect(p.is_male?).to be true
    end
    it 'should return false for anything integer or string representation of 1' do
      p = create(:person, gender: nil)
      expect(p.is_male?).to be false
      p = create(:person, gender: 2)
      expect(p.is_male?).to be false
      p = create(:person, gender: 'z')
      expect(p.is_male?).to be false
    end
  end

  context '#is_female?' do
    it 'should return female for integer 0' do
      p = create(:person, gender: 0)
      expect(p.is_female?).to be true
    end
    it 'should return female for string 0' do
      p = create(:person, gender: '0')
      expect(p.is_female?).to be true
    end
    it 'should return female for nil' do
      p = create(:person, gender: nil)
      expect(p.is_female?).to be true
    end
    it 'should return false for anything integer or string representation of 0' do
      p = create(:person, gender: 2)
      expect(p.is_female?).to be false
      p = create(:person, gender: '3')
      expect(p.is_female?).to be false
    end
  end

  context '#is_high_school?' do
    it 'should return true when person is in high school' do
      p = create(:person, lastAttended: 'HighSchool')
      expect(p.is_high_school?).to be true
    end
    it 'should return false when person is not in high school' do
      p = create(:person, lastAttended: 'University')
      expect(p.is_high_school?).to be false
    end
  end

  context '#full_name?' do
    it 'should merge the first and last names' do
      p = create(:person, first_name: 'Bob', last_name: 'Smith')
      expect(p.full_name).to eq('Bob Smith')
    end
  end

  context '#informal_full_name' do
    it 'should merge the nickname and last names' do
      p = create(:person, nickname: 'Bobby', last_name: 'Smith')
      expect(p.informal_full_name).to eq('Bobby Smith')
    end
  end

  context '#name_with_nick' do
    it 'should work without a preferred name' do
      p = create(:person, first_name: 'Bob', last_name: 'Smith')
      expect(p.name_with_nick).to eq('Bob Smith')
    end
    it 'should work with a preferred name' do
      p = create(:person, first_name: 'Bob', preferred_name: 'Bobby', last_name: 'Smith')
      expect(p.name_with_nick).to eq('Bob (Bobby) Smith')
    end
  end

  context '#long_name' do
    it 'should work without a middle name name' do
      p = create(:person, first_name: 'Bob', last_name: 'Smith')
      expect(p.long_name).to eq('Bob Smith')
    end
    it 'should work with a middle name name' do
      p = create(:person, first_name: 'Bob', middle_name: 'Bobby', last_name: 'Smith')
      expect(p.long_name).to eq('Bob Bobby Smith')
    end
  end

  context '#year' do
    it 'should work' do
      p = create(:person, yearInSchool: '5')
      expect(p.year).to eq('5')
    end
  end
  context '#year=' do
    it 'should work' do
      p = create(:person, yearInSchool: '5')
      p.year = '6'
      expect(p.year).to eq('6')
    end
  end
  context '#marital_status' do
    it 'single should work' do
      p = create(:person, maritalStatus: 'S')
      expect(p.marital_status).to eq('Single')
    end
    it 'married should work' do
      p = create(:person, maritalStatus: 'M')
      expect(p.marital_status).to eq('Married')
    end
    it 'divorced should work' do
      p = create(:person, maritalStatus: 'D')
      expect(p.marital_status).to eq('Divorced')
    end
    it 'widowed should work' do
      p = create(:person, maritalStatus: 'W')
      expect(p.marital_status).to eq('Widowed')
    end
    it 'separated should work' do
      p = create(:person, maritalStatus: 'P')
      expect(p.marital_status).to eq('Separated')
    end
  end

  #   context "#pic" do
  #     it "should work with no image" do
  #       p = create(:person)
  #       expect(p.pic).to eq("/images/nophoto_mini.gif")
  #     end
  #     it "should work with no image and a non-default size" do
  #       p = create(:person)
  #       expect(p.pic("big")).to eq("/images/nophoto_big.gif")
  #     end
  #     it "should work with an image set" do
  #       p = create(:person, image: "img.gif")
  #       expect(p.pic).to eq("")
  #     end
  #   end

  context '#email' do
    it 'should work with no email address set' do
      p = create(:person)
      expect(p.email).to be_nil
    end
    it 'should work with email address set' do
      p = create(:person)
      e = create(:fe_email_address, person: p)
      expect(p.email).to eq(e.email)
    end
    it 'should work with email address set from current address' do
      p = create(:person)
      e = create(:fe_address, address_type: 'current', email: 'email@email.com', person: p)
      expect(p.email).to eq(e.email)
    end
    it 'should work with email address set from permanent address' do
      p = create(:person)
      e = create(:fe_address, address_type: 'current', email: 'email@email.com', person: p)
      expect(p.email).to eq(e.email)
    end
    it 'should work with email address set from username' do
      u = create(:user, username: 'u1')
      p = create(:person, user: u)
      expect(p.email).to eq('u1')
    end
  end

  context '#primary_email_address=' do
    it 'should set all the old primary addresses primary column values to 0 and make a new email address' do
      p = create(:person)
      e = create(:fe_email_address, primary: true, email: 'email@email.com', person: p)
      p.primary_email_address = 'a@b.com'
      e.reload
      expect(e.primary).to be false
      expect(p.email_addresses.reload.length).to eq(2)
      expect(p.email).to eq('a@b.com')
    end
    it 'should reuse an old email address if possible' do
      p = create(:person)
      e1 = create(:fe_email_address, primary: true, email: 'email@email.com', person: p)
      e2 = create(:fe_email_address, primary: false, email: 'a@b.com', person: p)
      p.primary_email_address = 'a@b.com'
      e1.reload
      e2.reload
      expect(e1.primary).to be false
      expect(e2.primary).to be true
      expect(p.email_addresses.reload.length).to eq(2)
      expect(p.email).to eq('a@b.com')
    end
  end

  context '#set_phone_number' do
    it 'should set a new primary phone number' do
      p = create(:person)
      n = create(:fe_phone_number, primary: true, number: '12345', location: '333', person: p)
      p.set_phone_number '55555', '555', true
      n.reload
      expect(n.primary).to be false
      expect(p.phone_numbers.reload.length).to eq(2)
    end
    it 'should set an old phone record' do
      p = create(:person)
      n1 = create(:fe_phone_number, primary: true, number: '12345', location: '333', person: p)
      n2 = create(:fe_phone_number, primary: true, number: '55555', location: '555', person: p)
      p.set_phone_number '55555', '555', true
      n1.reload
      n2.reload
      expect(n1.primary).to be false
      expect(n2.primary).to be true
      expect(p.phone_numbers.reload.length).to eq(2)
    end
  end

  context '#is_secure?' do
    it 'should work for a basic staff' do
      p = create(:person)
      expect(p.is_secure?).to be false
    end
    it 'should work for a secure staff' do
      p = create(:person, isSecure: 'T')
      expect(p.is_secure?).to be true
    end
  end

  context '#find_exact' do
    it 'should match by email address' do
      p = create(:person)
      a = create(:fe_address, address_type: 'current', email: 'email@email.com', person: p)
      e = create(:fe_email_address, primary: true, email: 'email@email.com', person: p)
      r = Person.find_exact(nil, e)
      expect(r).to eq(p)
    end
    it 'should match by username address' do
      p = create(:person)
      u = create(:user, username: 'email@email.com', person: p)
      e = create(:fe_email_address, primary: true, email: 'email@email.com', person: p)
      r = Person.find_exact(nil, e)
      expect(r).to eq(p)
    end
  end

  context '#fix_acct_no' do
    it 'should work' do
      expect(Person.fix_acct_no('S')).to eq('000000000S')
    end
  end

  context '#to_s' do
    it 'should work' do
      p = create(:person)
      expect(p.to_s).to eq(p.informal_full_name)
    end
  end

  context '#apply_omniauth' do
    it 'should work' do
      p = Person.new
      p.apply_omniauth('first_name' => 'fn', 'last_name' => 'ln')
      expect(p.first_name).to eq('fn')
      expect(p.last_name).to eq('ln')
    end
  end

  context '#phone' do
    it 'should return empty string if no address' do
      p = create(:person)
      expect(p.phone).to eq('')
    end
    it 'should return cell phone if present' do
      p = create(:person)
      a = create(:fe_address, cell_phone: '12345', home_phone: '12346', work_phone: '12347', address_type: 'current', email: 'email@email.com', person: p)
      expect(p.phone).to eq('12345')
    end
    it 'should return home phone if present and no cell' do
      p = create(:person)
      a = create(:fe_address, cell_phone: nil, home_phone: '12346', work_phone: '12347', address_type: 'current', email: 'email@email.com', person: p)
      expect(p.phone).to eq('12346')
    end
    it 'should return work phone if present and no cell or home phone' do
      p = create(:person)
      a = create(:fe_address, cell_phone: nil, home_phone: nil, work_phone: '12347', address_type: 'current', email: 'email@email.com', person: p)
      expect(p.phone).to eq('12347')
    end
  end

  context '#async_push_to_global_registry' do
    it 'should work' do
      GlobalRegistry.access_token = 'access_token'
      GlobalRegistry.base_url = 'https://globalregistry.com/'

      stub_request(:get, 'https://globalregistry.com/entity_types?filters%5Bname%5D=person&filters%5Bparent_id%5D=')
        .to_return(status: 200, body: '{ "entity_types": [ { "fields": [ { "name": "something" } ] } ] }', headers: {})

      Person.columns_to_push.each do |column_hash|
        stub_request(:post, 'https://globalregistry.com/entity_types')
          .with(body: "{\"entity_type\":{\"name\":\"#{column_hash[:name]}\",\"parent_id\":null,\"field_type\":\"#{column_hash[:type]}\"}}")
          .to_return(status: 200, body: '', headers: {})
      end

      u = create(:user, globallyUniqueID: '55555', fb_user_id: '55556')
      create(:authentication, user: u, provider: 'facebook', uid: 'fb_uid')
      create(:authentication, user: u, provider: 'google_apps', uid: 'gapi_uid')
      p = create(:person, user: u, account_no: 'account_no', gender: 1, maritalStatus: 'S', birth_date: Date.new(1975, 1, 1))

      stub_request(:post, 'https://globalregistry.com/entities')
        .with(body: { entity:               { 'person' =>                 { 'client_integration_id' => p.id,
                                                                            'client_updated_at' => p.updated_at,
                                                                            'id' => p.id,
                                                                            'last_name' => p.last_name,
                                                                            'first_name' => p.first_name,
                                                                            'gender' => 'Male',
                                                                            'work_in_us' => 'true',
                                                                            'us_citizen' => 'true',
                                                                            'marital_status' => 'Single',
                                                                            'account_number' => 'account_no',
                                                                            'is_secure' => false,
                                                                            'birth_year' => 1975,
                                                                            'birth_month' => 1,
                                                                            'birth_day' => 1,
                                                                            'authentication' => { 'relay_guid' => '55555', 'facebook_uid' => 'fb_uid', 'google_apps_uid' => 'gapi_uid' } } } }.to_json
            )
        .to_return(status: 200, body: '{ "entity": { "person": { "id": 1 } } }', headers: {})

      p.async_push_to_global_registry
    end
  end

  context 'Person#global_registry_entity_type_name' do
    it 'should return a string' do
      expect(Person.global_registry_entity_type_name.class).to be String
    end
  end
end
