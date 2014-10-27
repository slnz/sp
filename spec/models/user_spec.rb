require 'spec_helper'

describe User do
  context '#find_or_create_from_guid_or_email' do
    it "creates a person associated with the new user" do
      user = User.find_or_create_from_guid_or_email('a', 'a@example.com', 'John', 'Doe')
      user.reload
      expect(user.person).to_not be_nil
    end
  end

  context '#find_or_create_from_cas' do
    it 'should work' do
      atts = { 'ssoGuid' => '123', 'first_name' => 'first_name', 'lastName' => 'last_name', 'username' => 'a@b.com' }
      expect(User).to receive(:find_or_create_from_guid_or_email).with('123', 'a@b.com', 'first_name', 'last_name')
      User.find_or_create_from_cas(atts)
    end
  end

  context '#find_or_create_from_guid_or_email' do
    it 'should update the email address if a match is found by guid but emails are different' do
      u = create(:user, globallyUniqueID: 'guid', email: 'a@b.com')
      User.find_or_create_from_guid_or_email('guid', 'email@email.com', 'first_name', 'last_name', true)
      u.reload
      expect(u.username).to eq('email@email.com')
    end
  end

  context '#find_or_create_from_guid_or_email' do
    it 'should update the guid if a match is found by email but guid is different from the one used to log in' do
      $a = true
      u = create(:user, globallyUniqueID: 'nomatchguid', username: 'matchemail@match.com')
      User.find_or_create_from_guid_or_email('guid', 'matchemail@match.com', 'first_name', 'last_name', true)
      u.reload
      expect(u.globallyUniqueID).to eq('guid')
    end
  end

  context '#apply_omniauth' do
    it 'should create a new authentication' do
      u = create(:user)
      allow(Authentication).to receive(:find_by_provider_and_uid).with('provider', 'uid').and_return(false)
      u.apply_omniauth({'info' => { 'email' => 'a@b.com' }, 'provider' => 'provider', 'uid' => 'uid' })
      u.reload
      expect(u.authentications.length).to be 1
    end
  end

  context '#stamp_last_login' do
    it 'should stamp the last login' do
      u = create(:user)
      u.stamp_last_login
    end
  end

  context '#stamp_column' do
    it 'should stamp_column' do
      p = create(:person)
      u = create(:user, person: p)
      u.stamp_column(:date_attributes_updated)
      u.person.reload
      expect(u.person.date_attributes_updated > 10.seconds.ago).to be true
    end
  end

  context '#create_person_and_address' do
    it 'should create a new user, person and address' do
      u = create(:user)
      u.create_person_and_address({ first_name: 'first_name' })
      u.reload
      expect(u.person).to_not be_nil
      expect(u.person.current_address).to_not be_nil
      expect(u.person.first_name).to eq('first_name')
    end
  end

  context '#create_person_and_address' do
    it 'should create a new user, person and address' do
      u = create(:user)
      u.create_person_and_address({ first_name: 'first_name' })
      u.reload
      expect(u.person).to_not be_nil
      expect(u.person.current_address).to_not be_nil
      expect(u.person.first_name).to eq('first_name')
    end
  end

  context '#create_person_from_omniauth' do
    it 'should create a new user, person and address' do
      u = create(:user)
      u.create_person_from_omniauth({ 'first_name' => 'first_name', 'last_name' => 'last_name' })
      u.reload
      expect(u.person).to_not be_nil
      expect(u.person.current_address).to_not be_nil
      expect(u.person.first_name).to eq('first_name')
    end
  end

  context '#create_new_user_from_cas' do
    it 'should create a new user, person and address' do
      u = User.create_new_user_from_cas('username@email.com', { 'ssoGuid' => 'guid', 'firstName' => 'first_name', 'lastName' => 'last_name' })
      u.reload
      expect(u.person).to_not be_nil
      expect(u.person.current_address).to_not be_nil
      expect(u.person.first_name).to eq('first_name')
    end
    it 'should find an existing user when only the username matches' do
      u = create(:user, username: 'username@email.com')
      User.create_new_user_from_cas('username@email.com', { 'ssoGuid' => 'guid', 'firstName' => 'first_name', 'lastName' => 'last_name' })
      u.reload
      expect(u.globallyUniqueID).to eq('guid')
    end
    it 'should find an existing user by guid' do
      u = create(:user, username: 'nomatch', globallyUniqueID: 'guid')
      User.create_new_user_from_cas('username@email.com', { 'ssoGuid' => 'guid', 'firstName' => 'first_name', 'lastName' => 'last_name' })
      u.reload
      expect(u.username).to eq('username@email.com')
    end
    it 'should find an existing user by guid' do
      u = create(:user, username: 'nomatch', globallyUniqueID: 'guid')
      User.create_new_user_from_cas('username@email.com', { 'ssoGuid' => 'guid', 'firstName' => 'first_name', 'lastName' => 'last_name' })
      u.reload
      expect(u.username).to eq('username@email.com')
    end
  end
end
