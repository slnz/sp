class ApplicationsController < ApplicationController
  before_filter :redirect_to_closed, :except => :closed
  
  def index
    
  end
  
  def closed
    
  end
  
  protected
    def redirect_to_closed
      unless logged_in? && current_user.developer?
        redirect_to :action => :closed 
        return false
      end
    end
end
