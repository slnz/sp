require 'spec_helper'

describe UsersController do
  context '#create' do
    it 'creates a user with email, first name, last name' do
      expect {
        post :create, email: "royallil@email.meredith.edu", person: {firstName: "Lillie", lastName: "Royal"}
      }.to change(User, :count).by(1)
    end
  end
end
