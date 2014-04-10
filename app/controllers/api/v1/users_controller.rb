class Api::V1::UsersController < Api::V1::BaseController

  def index
    users = add_includes_and_order(User.all)
    render render_options(users)
  end

  def show
    user = User.find(params[:id])
    render render_options(user)
  end

  private

  def available_includes
    []
  end

end
