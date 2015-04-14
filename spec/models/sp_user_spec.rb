require 'spec_helper'

describe SpUser do
  context '#creatable_user_types_array' do
    it 'should work with no params passed in' do
      person = create(:person)
      sp_user = create(:sp_user, person: person)
      expect(sp_user.creatable_user_types_array).to eq([])
    end
  end

  context '#can_edit_project?' do
    it 'should allow someone to edit a project they are directing' do
      user = create(:user)
      person = create(:person, user: user)
      sp_user = create(:sp_user, person: person, user: user, type: 'SpDirector')
      project = create(:sp_project)
      sp_staff = create(:sp_staff_pd, sp_project: project, person: person)
      sp_user.reload
      expect(sp_user.can_edit_project?(project)).to be true
    end
    it 'should not allow someone to edit a project they are not directing' do
      user = create(:user)
      person = create(:person, user: user)
      sp_user = create(:sp_user, person: person, user: user, type: 'SpDirector')
      project = create(:sp_project)
      project2 = create(:sp_project)
      sp_staff = create(:sp_staff_pd, sp_project: project, person: person)
      sp_user.reload
      expect(sp_user.can_edit_project?(project2)).to be false
    end
  end

  context '#region' do
    it 'should work' do
      user = create(:user)
      person = create(:person, user: user, region: 'GL')
      sp_user = create(:sp_user, person: person, user: user, type: 'SpDirector')
      sp_user.region
    end
  end

  context '#region' do
    it 'should work' do
      user = create(:user)
      person = create(:person, user: user, region: 'GL')
      sp_user = create(:sp_user, person: person, user: user, type: 'SpDirector')
      sp_user.region
    end
  end
end
