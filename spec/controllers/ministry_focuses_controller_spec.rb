require 'spec_helper'

describe MinistryFocusesController do
  context '#index' do
    it 'should render' do
      create(:sp_ministry_focus)
      get :index
    end
  end
end
