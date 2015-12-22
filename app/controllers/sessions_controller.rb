class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  	else
  		#fix flash - hartl 8.1.5
  		flash[:danger] = 'Invalid email/password combination'
  	render 'new'
  end
end

  def destroy
  end

end
