class Admin::PeopleController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  before_filter :get_person, :only => [:edit, :destroy, :update, :show]
  respond_to :html, :js
  def show
    respond_with(@person)
  end
  
  def update
    @person.update_attributes(params[:person])
    respond_with(@person)
  end
  
  protected
    def get_person
      @person = Person.find(params[:id])
    end
end
