class UsersController < ApplicationController
  skip_before_action :ssm_login_required
  def index
    redirect_to action: 'new'
  end

  def new
    @user = User.new
    @person = Person.new
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @person.apply_omniauth(session[:omniauth]['info'])
      @user.valid?
      @person.valid?
      @user.errors[:omniauth] = true if @user.errors.present? || @person.errors.present?
    end
  end

  def create
    @user = User.new(username: params[:email])
    @person = Person.new(person_params)
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @person.apply_omniauth(session[:omniauth]['info'])
    end
    @email_address = @person.email_addresses.new(email: params[:email])
    if @user.valid? && @person.valid? && @email_address.valid?
      @user.save!
      @person.user = @user
      @person.save!
      Address.create(person: @person, email: @user.username, address_type: 'current')
      login_user!(@user)
      session[:omniauth] = nil
      redirect_to(root_path)
    else
      render :new
    end
  end

  private

  def person_params
    params.require(:person).permit(:first_name, :last_name)
  end
end
