require 'aws-sdk'

class UsersController < ApplicationController

  # skip_filter other access restrictions...
  before_action :restrict_access, only: [:aws_auth]
  skip_before_action :verify_authenticity_token


  def user_auth

    defaults = {
      id: nil,
      email: nil,
      public_id:88888888,
      authentication_hash: nil
    }
    user = User.where(email: params[:email]).first

    if user
      answer = user.as_json(only: defaults.keys)
      answer[:public_id] = 9999999
      answer[:user_exists] = true
      answer[:success] = user.valid_password?(params[:password])
    else
      answer = defaults
      answer[:success] = false
      answer[:user_exists] = false
    end

    respond_to do |format|
      format.json { render json: answer }
    end

  end


   private

  def restrict_access
    head :unauthorized unless request.headers['accessToken'] == ENV["auth_access_token"]

  end

end