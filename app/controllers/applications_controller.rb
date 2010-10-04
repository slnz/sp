class ApplicationsController < ApplicationController
  before_filter :redirect_to_closed, :except => :closed
  
  def index
    
  end
  
  def closed
    
  end
  
  protected
    def redirect_to_closed
      unless current_user.developer?
        redirect_to :closed 
        return false
      end
    end
end
