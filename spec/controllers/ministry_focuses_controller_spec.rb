require 'spec_helper'

describe MinistryFocusesController do
  context '#index' do
    it 'should render' do
      get :index, format: 'xml'
    end
  end
end
