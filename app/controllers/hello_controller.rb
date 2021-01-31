class HelloController < ApplicationController

def index
  print "*************** in Hello Controller***********************\n"

  print  session[:cognito_error_message]
  if session[:cognito_error_message]
    @accountStatus =  session[:cognito_error_message]
  elsif   session[:is_new_user]
    @accountStatus =  'new user'
  else
    @accountStatus = 'Confirmed'

  end
  @greeting = "Index action says: Hello !"
   @user = current_user
   @clientId = ENV["AWS_COGNITO_CLIENT_ID"]
 end
end