class UsersController < ApplicationController

  # skip_filter other access restrictions...
  before_action :restrict_access, only: [:aws_auth]
  skip_before_action :verify_authenticity_token

  # (...)

  def aws_auth

    defaults = {
      id: nil,
      first_name: nil,
      last_name: nil,
      email: nil,
      authentication_hash: nil
    }
    user = User.where(email: aws_auth_params[:email]).first

    if user
      answer = user.as_json(only: defaults.keys)
      answer[:user_exists] = true
      answer[:success] = user.valid_password?(aws_auth_params[:password])
    else
      answer = defaults
      answer[:success] = false
      answer[:user_exists] = false
    end

    respond_to do |format|
      format.json { render json: answer }
    end

  end

  # (...)

   private

  def restrict_access
    head :unauthorized unless params[:access_token] =="IhDqE1QyEBmZxPwsUdWPEpTpmzloa6RE7rEsWiYa80h2YIwiEsh"
  end

end