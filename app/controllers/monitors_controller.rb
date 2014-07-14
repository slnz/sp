class MonitorsController < ApplicationController
  def lb
    User.first
    render text: 'OK'
  end
end
