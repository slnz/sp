class Api::V1::RegionsController < Api::V1::BaseController

  def index
    render render_options(Region.all, params[:order] || 'region')
  end

end
