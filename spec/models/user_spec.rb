require 'spec_helper'

describe User do
  context '.find_or_create_from_guid_or_email' do
    it "creates a person associated with the new user" do
      user = User.find_or_create_from_guid_or_email('a', 'a@example.com', 'John', 'Doe')
      user.reload
      expect(user.person).to_not be_nil
    end
  end

end
